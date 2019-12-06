package re.BridgeTerm;

//import com.amoebacode.ftp.FTPClient;

import java.io.IOException;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.util.Calendar;
import java.util.Scanner;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Environment;
import android.os.PowerManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;


public class BridgeTerm extends Activity implements SensorEventListener, LocationListener {


	// we're using a lot of global to reduce overhead in creating/destroying variables if at all possible: less for the GC to do and less memory move-arounds, should increase stability.

	public static BridgeTerm soliton = null;
	// constants
	public static final int AverageVals = 10;
	public static final int Roundoff = 10;
	//	public static double COGAngleCorrectionSpeed = 99.9;

	// ui elements
	public static TextView myIPaddress;
	public static TextView txtH, txtP, txtR;
	public static TextView txtA;
	public static TextView txtLat, txtLon;
	public static TextView txtSerial, txtNMEA;
	public static TextView txtDebug;

	public static boolean emergencydisklessmode = false; // trigger this if the logger cannot write to sd
	// actual nav data: sensors
	public static float[] Headings = new float[AverageVals]; // for averaging
	public static float HeadingDelta = (float) 0.0;
	public static float HeadingOutput = (float) 0.0;

	public static float[] Pitches = new float[AverageVals]; // for averaging
	public static float PitchDelta = (float) 0.0;
	public static float PitchOutput = (float) 0.0;

	public static float[] Rolls = new float[AverageVals]; // for averaging
	public static float RollDelta = (float) 0.0;
	public static float RollOutput = (float) 0.0;

	// actual nav data: gps (I know I could just define a location here but I'd rather have separate variables if I decide to do interpolation in here as well).
	public static double Latitude = 400.0;
	public static double Longitude = 400.0;
	public static double Altitude = -1;
	public static double COG = -1;
	public static double Speed = -1;
	public static double GPSError = -1;

	// logging stuff
	public static String LogWhereDir = "/sdcard/www/";
	public static String LogWhereFilename="logfile";
	public static String LogWhereTimestamp = "";
	public static String LogWhereExt =".log";
	public static String LogWhere = LogWhereDir + LogWhereFilename+LogWhereTimestamp+LogWhereExt;
	public static boolean AtLeastOneFix = false;
	public static final String PREFS_NAME = "loggerprefs";

	public static int    LogEvery = 5; // seconds
	public static long   LogElapsed = 0; // lets the user set up logfiles
	public static long   LogSize = 0;
	public static	int    TimestampType = 7; // i hate java enum so: 5 to 10 as per the menu options

	// saves on passing arguments
	public static String LogWhat = "";
	public static String LastSerial = ""; // must treat it as asynchronous since we don't know what if anything is coming in
	public static String LastNMEA = "";
	public static String LastSensors = ""; 
	public static String LastLoc = ""; 

	// watchdog
	public static boolean watchdog = true;
	
	public static Button com0button;
	public static Button com1button;
	public static Button com2button;
	public static Button com3button;
	
	public static EditText comout;

	// navcom style messagebox
	public static String Debug1 = "";
	public static String Debug2 = "";

	// serial output

	public static String NMEAOut = "";
	public static final boolean outputserial = false;
	// preferences
	public static SharedPreferences settings;
	public static SharedPreferences.Editor sw;

	// provider thingies

	// for HPR and accels
	public static SensorManager mSensorManager;
	public static SensorManager mCompassManager;

	// for coords
	public static LocationManager mLocationManager;

	// for serial data
	public static FileInputStream serialnmea;
	public static FileInputStream serialext;
	public static DataInputStream nmeain;
	public static DataInputStream serialin;

	public static boolean NMEAthere = false;
	public static boolean COMthere = false;
	// secondary serial buffer
	public static String feedme = "";

	public static PowerManager pm;
	public static PowerManager.WakeLock wl1,wl2;
	public static Window mywindow; 
	
	public static File c0,c1,c2,c3,ct;


	// for prefs file (this is an abomination, but that's how they want to do it
	public static int RunOnStartup = 1;

	public static void DebugMsg(String newstring)
	{
		Debug1 = Debug2;
		Debug2 = newstring;
		txtDebug.setText(Debug1 + "\n" + Debug2);
		return;
	}

	public static void LoadPrefs() {
		LogWhereDir = settings.getString("LogWhereDir", "/sdcard/www/");
		LogWhereFilename = settings.getString("LogWhereFilename", "logfile");
		LogEvery = settings.getInt("LogEvery", 5);
		TimestampType = settings.getInt("TimestampType", 7);
		RunOnStartup = settings.getInt("RunOnStartup", 1);
	}

	public static void SavePrefs() {
		sw.putString("LogWhereDir", LogWhereDir);
		sw.putString("LogWhereFilename", LogWhereFilename);
		sw.putInt("LogEvery", LogEvery);
		sw.putInt("TimestampType", TimestampType);
		sw.putInt("RunOnStartup", RunOnStartup);
		sw.commit();
		DebugMsg("Preferences saved.");
	}

	public static void WipePrefs() {
		sw.clear();
		sw.commit();
		LoadPrefs();
		DebugMsg("Preferences cleared.");
	}

	public static void nuketheapp()
	{
		try { serialnmea.close(); } catch (Exception e) {} // close serial port
		try { serialin.close(); } catch (Exception e) {} // close serial port
		try {mLocationManager.removeUpdates(soliton);} catch (Exception e) {} // turn off gps
		android.os.Process.killProcess(android.os.Process.myPid()); // NUKE
		soliton.finish();
	}


	public static void dealwithstartup()
	{
	}

	/** Called when the activity is first created. Sorta like main() also see onStart*/
	@Override
	public void onCreate(Bundle savedInstanceState) {
		
		LogWhereDir = Environment.getDownloadCacheDirectory().getPath()+"/www/";
		if (soliton == null)
			soliton = this;
		else
			android.os.Process.killProcess(android.os.Process.myPid()); // NUKE

		super.onCreate(savedInstanceState);

		try {
			Runtime.getRuntime().exec("chmod 777 "+getCacheDir().getAbsolutePath());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String path=getCacheDir().getAbsolutePath()+"/";
		Log.e("PB_IN","D:"+path);
		c0= new File(path+"COM0");//"/data/local/COM0");
		c1= new File(path+"COM1");//"/data/local/COM1");
		c2= new File(path+"COM2");//"/data/local/COM2");
		c3= new File(path+"COM3");//"/data/local/COM3");
		ct= new File(path+"COMTEMP");//"/data/local/COMTEMP");
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		


		pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
		wl1 = pm.newWakeLock(PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.SCREEN_DIM_WAKE_LOCK, "Datalogger"); 
		wl2 = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Datalogger"); 
		settings = getSharedPreferences(PREFS_NAME, MODE_WORLD_WRITEABLE);
		sw = settings.edit();

		LoadPrefs();

		setContentView(R.layout.main);
		initGUIComponents();
		dealwithstartup();


		// try to make the log directory accessible, ignore errors if it's already there (must go somewhere)
		boolean success = (new File(LogWhereDir)).mkdir();
		if (success)
			DebugMsg("Created log directory");







		UpdateTimeStamp();
		LogWhere = LogWhereDir + LogWhereFilename+LogWhereTimestamp+LogWhereExt; // for visualization

		mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
		mSensorManager.registerListener(this, mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) , SensorManager.SENSOR_DELAY_UI);

		mCompassManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
		mCompassManager.registerListener(this, mCompassManager.getDefaultSensor(Sensor.TYPE_ORIENTATION) , SensorManager.SENSOR_DELAY_GAME); // faster for interpolation

		mLocationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, this); // this actually turns on the gps



		mywindow = getWindow();
		//setBright(1.0);


		
		
		com0button = (Button) findViewById(R.id.button0);
		com1button = (Button) findViewById(R.id.button1);
		com2button = (Button) findViewById(R.id.button2);
		com3button = (Button) findViewById(R.id.button3);
		comout = (EditText) findViewById(R.id.editText1);
		
		
		com0button.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Log.e("PB_IN","S0:"+comout.getText());
				comout.setText("");
			}
		});

		com1button.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Log.e("PB_IN","S1:"+comout.getText());
				comout.setText("");
			}
		});

		com2button.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Log.e("PB_IN","S2:"+comout.getText());
				comout.setText("");
			}
		});

		com3button.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				Log.e("PB_IN","S3:"+comout.getText());
				comout.setText("");
			}
		});
		
		
		AsyncLogger(14000); // should be less than phone backlight timeout


	}


	public static void uppy() {
		/*
		if (false)
		{
			FTPClient ftpClient = new FTPClient(false);//debugspam off please!
			try {
				ftpClient.openConnection("data.etracengineering.net");
				ftpClient.login("android", "bargetrac");
				ftpClient.setTransferType(true);
				ftpClient.uploadFile("/DROID_"+LogWhereFilename+LogWhereTimestamp+LogWhereExt, LogWhere);
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				try {
					ftpClient.closeConnection();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		*/
	}

	public static void uppytest() {
		/*
		if (true)
		{
			FTPClient ftpClient = new FTPClient(true);
			try {
				ftpClient.openConnection("data.etracengineering.net");
				ftpClient.login("android", "bargetrac");
				ftpClient.appendString("/DROID_sdcard_is_full_or_dead.txt", LogWhat);
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				try {
					ftpClient.closeConnection();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		*/
	}


	public static void AsyncLogger(final long setevery) {
		new CountDownTimer(setevery, 1000) {
			public void onTick(long millisUntilFinished) {
				wl2.acquire();
				//long secs = millisUntilFinished / 1000;
				//setBright(brightness - (1.0/16.0));

				// for preventing sleep mode: reset every second. do NOT keep wake lock outside of a function, it causes mess.
				//wl1.acquire();
				if (--uploadcounter < 0)
				{
					uppy();
					uploadcounter = uploadtime;
				}

				if (++LogElapsed >= LogEvery)
				{
					LogElapsed = 0;
					DoLogging("");
					LogSize = LogSize + LogWhat.length();
					Log.i("Position Eater",":"+HeadingOutput+":"+PitchOutput+":"+RollOutput);
				}

				// other general maintenance to do once per second
				if (LogSize > 1000000000 ){ // prevent fat32 mixup
					LogWhereFilename = LogWhereFilename+"_";
					LogWhere = LogWhereDir + LogWhereFilename+LogWhereTimestamp+LogWhereExt; // for visualization
					LogSize = 0;
					DebugMsg("Logfile too large, switching to new logfile.");
				}

				// update text box
				if (AtLeastOneFix)
					txtLon.setText("Logging every "+LogEvery+ " seconds ["+(LogEvery-LogElapsed)+"]. Log size so far is ~" + ((LogSize/1024)+1)+"kb\nLogging to "+LogWhere); // note intentional overestimation of file size
				else
					txtLon.setText("Will log every "+LogEvery+ " seconds ["+(LogEvery-LogElapsed)+"]. Waiting for first fix.\nWill log to "+LogWhere); // note intentional overestimation of file size
				//wl1.release();
				wl2.release();
			}

			public void onFinish() {
				AsyncLogger(setevery);
			}
		}.start();
	}


	public void onStop(){restart();};
	public void onDestroy(){restart();};
	public static void onQuit(){restart();};

	public static void restart() {
		if (watchdog)
		{
			//setBright(1.0); // let's not be assholes and turn the screen back on -- it can be turned back off later anyway
			Runtime r = Runtime.getRuntime();
			String[] cmd2 = new String[]{"am","start","-a","android.intent.action.MAIN","-n","re.BridgeTerm/re.BridgeTerm.BridgeTerm"};
			try {r.exec(cmd2);} catch (Exception e1) {}
			nuketheapp(); // is being restarted by commandline anyway
		}
	}

	public void initGUIComponents() {

		//txtA = (TextView) findViewById(R.id.txtA);
		//txtH = (TextView) findViewById(R.id.txtH);
		//txtP = (TextView) findViewById(R.id.txtP);
		//txtR = (TextView) findViewById(R.id.txtR);
		txtLat = (TextView) findViewById(R.id.txtLat);
		txtLat.setMovementMethod(new ScrollingMovementMethod());
		txtLon = (TextView) findViewById(R.id.txtLon);
		txtLon.setMovementMethod(new ScrollingMovementMethod());
		txtSerial = (TextView) findViewById(R.id.txtSerial);
		txtSerial.setMovementMethod(new ScrollingMovementMethod());
		txtNMEA = (TextView) findViewById(R.id.txtNMEA);
		txtNMEA.setMovementMethod(new ScrollingMovementMethod());
		txtDebug = (TextView) findViewById(R.id.txtDebug);
		txtDebug.setMovementMethod(new ScrollingMovementMethod());
	}


	private void addMessage(String msg, TextView mTextView){
	    // append the new string
	    mTextView.append(msg);
	    // find the amount we need to scroll.  This works by
	    // asking the TextView's internal layout for the position
	    // of the final line and then subtracting the TextView's height
	    final int scrollAmount = mTextView.getLayout().getLineTop(mTextView.getLineCount())
	            -mTextView.getHeight();
	    // if there is no need to scroll, scrollAmount will be <=0
	    if(scrollAmount>0)
	        mTextView.scrollTo(0, scrollAmount);
	    else
	        mTextView.scrollTo(0,0);
	}
	
	
	// if the user hits menu


	public boolean onCreateOptionsMenu(Menu menu) {
		// these show up in the primary screen: out of order for display reasons

		//setBright(1.0);
//		SubMenu freqmenu = menu.addSubMenu(0,99,0,"Log frequency");
//		SubMenu logmenu = menu.addSubMenu(0,99,0,"Logfile options");
//		SubMenu setmenu = menu.addSubMenu(0,99,0,"Persistence");


		menu.add(0, 0, 0, "(!) QUIT (!)");
//		freqmenu.add(0, 1, 0, "Log More Often");
//		freqmenu.add(0, 2, 0, "Log Less Often");
//		freqmenu.add(0, 3, 0, "Log More Often (5)");
//		freqmenu.add(0, 4, 0, "Log Less Often (5)");
		// these show up in the secondary screen
//		logmenu.add(0, 5, 0, "Single logfile");
//		logmenu.add(0, 6, 0, "Logfile every minute");
//		logmenu.add(0, 7, 0, "Logfile every hour");
//		logmenu.add(0, 8, 0, "Logfile every 6 hours");
//		logmenu.add(0, 9, 0, "Logfile every 12 hours");
//		logmenu.add(0, 10, 0, "Logfile every day");
//		setmenu.add(0, 14, 0, "Toggle running logger on startup");
//		setmenu.add(0, 11, 0, "Reload settings");
//		setmenu.add(0, 12, 0, "Save settings");
//		setmenu.add(0, 13, 0, "Default settings");

		return true;
	}

	public boolean onPrepareOptionsMenu(Menu menu) {
		//setBright(1.0);
		LogElapsed -= 30; // give the user time to change selections
		return true;
	}

	public void onOptionsMenuClosed (Menu menu){
		//setBright( 1.0);
		LogElapsed += 60; // give the user time to change selections, compensate for 2 levels of menu
	}

	public static double brightness =  1.0;
	public static void setBright(double value) {
		brightness = value;
		if (brightness < (1.0/128.0))
			brightness = (1.0/128.0); // if you set this to 0, the phone MAY drop the wakelock, so just set it low enough that the light is turned off.

		if (brightness > 1.0)
			brightness = 1.0; // more than 1 does nothing, but let's cap it just in case.

		WindowManager.LayoutParams lp = mywindow.getAttributes();
		lp.screenBrightness = (float)brightness;
		mywindow.setAttributes(lp);
	}

	/* Handles item selections */
	public boolean onOptionsItemSelected(MenuItem item) {
		//setBright(1.0);
		LogElapsed += 30;
		switch (item.getItemId()) {
		case 1:
			if (--LogEvery < 1) LogEvery = 1; DebugMsg("Changed logging frequency."); break;
		case 2:
			if (++LogEvery > 3600) LogEvery = 3600; DebugMsg("Changed logging frequency."); break;
		case 3:
			LogEvery -= 5; if (LogEvery < 1) LogEvery = 1; DebugMsg("Changed logging frequency."); break;
		case 4:
			LogEvery += 5; if (LogEvery > 3600) LogEvery = 3600; DebugMsg("Changed logging frequency."); break;
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10: TimestampType = item.getItemId(); UpdateTimeStamp(); DebugMsg("Changed logging timestamp setting."); break;
		case 11: LoadPrefs(); break;
		case 12: SavePrefs(); break;
		case 13: WipePrefs(); break;
		case 14: RunOnStartup = 1 - RunOnStartup; dealwithstartup(); sw.putInt("RunOnStartup", RunOnStartup); sw.commit(); break;



		case 0:
		{
			watchdog = false; // prevent restart
			nuketheapp();
			return true;
		}
		default: return false;
		}

		LogWhere = LogWhereDir + LogWhereFilename+LogWhereTimestamp+LogWhereExt; // for visualization
		return true;
	}	



	// just update the course variables as if we were reading a NMEA string
	public void onLocationChanged(Location loc) {
		if (AtLeastOneFix == false)
			DebugMsg("First fix obtained, log started.");

		AtLeastOneFix = true;
		Latitude = loc.getLatitude();
		Longitude = loc.getLongitude();
		if (loc.hasAltitude())
			Altitude = loc.getAltitude();
		if (loc.hasBearing())
			COG = loc.getBearing();
		if (loc.hasSpeed())
			Speed = loc.getSpeed();
		if (loc.hasAccuracy())
			GPSError = loc.getAccuracy();

		LastLoc = Double.toString(Latitude) + "\t"+ Double.toString(Longitude)+"\t" + Double.toString(Altitude)+ "\t" + Double.toString(GPSError) + "\t" + Double.toString(COG)+ "\t" + Double.toString(Speed) +"\t";

		txtLat.setText("Lat: " + Double.toString(Latitude) + "\tLon: "+ Double.toString(Longitude)+"\nCOG: " + Double.toString(COG)+"\t\tSpeed:"+Double.toString(Speed)+"\t\tError:"+Double.toString(GPSError)+"m");

		// read NMEA stuff -- happens once a second anyway.
		String feedme;
		String NMEAwanted;
		int keepparsing = 2; // we want two sentences 

		feedme = "";
		if (NMEAthere)
			try {
				while ((nmeain.available() > 0) && (keepparsing > 0))
				{

					NMEAwanted = nmeain.readLine();
					if (NMEAwanted.indexOf("GPGGA") > 0) // i THINK we only need gprmc here so let's just go with this. remember: always ends with $PSTIS so use that
					{
						feedme = feedme + NMEAwanted.substring(NMEAwanted.indexOf("$")) + " \n"; //nmeain.readLine();
						keepparsing = keepparsing - 1;
					}
					if (NMEAwanted.indexOf("GPRMC") > 0) // i THINK we only need gprmc here so let's just go with this. remember: always ends with $PSTIS so use that
					{
						feedme = feedme + NMEAwanted.substring(NMEAwanted.indexOf("$")) + " \n"; //nmeain.readLine();
						keepparsing = keepparsing - 1;
					}

				}

			} catch (Exception e) { /*feedme = "NMEA unreadable\t" + e.toString()+"\t";*/ } // try to rebuild GPRMC or GPGGA?

		if (feedme == "") {
			feedme = "N/A\tN/A\n";
		}

		txtNMEA.setText(feedme);
		LastNMEA = feedme;


	}

	static int uploadcounter = 60; // always upload the first minute
	static int uploadtime = 60; // always upload the first minute

	public static void UpdateTimeStamp() {
		Calendar cd = Calendar.getInstance();
		LogWhereTimestamp = "-"+ cd.get(Calendar.YEAR) +
				String.format("%02d",cd.get(Calendar.MONTH)+1) +
				String.format("%02d",cd.get(Calendar.DAY_OF_MONTH)) + "-" +
				String.format("%02d",cd.get(Calendar.HOUR_OF_DAY)) +
				String.format("%02d",cd.get(Calendar.MINUTE)) +
				String.format("%02d",cd.get(Calendar.SECOND));
	}


	public static void DoLogging(String LogThis){
		if (AtLeastOneFix)
			if (LogThis == "")
				LogThis = "\t";
		LogWhat = LastNMEA + LastLoc + LastSensors + LastSerial + LogThis + "\n";


		// these show up in the secondary screen
		//     	    menu.add(0, 5, 0, "Single logfile");
		//     	    menu.add(0, 6, 0, "Logfile every minute");
		//     	    menu.add(0, 7, 0, "Logfile every hour");
		//     	    menu.add(0, 8, 0, "Logfile every 6 hours");
		//     	    menu.add(0, 9, 0, "Logfile every 12 hours");
		//     	    menu.add(0, 10, 0, "Logfile every day");

		UpdateTimeStamp();
		LogWhere = LogWhereDir + LogWhereFilename+LogWhereTimestamp+LogWhereExt;
		// Append stuff to file and close immediately
		try{
			FileWriter fstream = new FileWriter(LogWhere,true);
			BufferedWriter outlog = new BufferedWriter(fstream,4096);
			outlog.write(LogWhat);
			outlog.close();
		}
		catch (Exception e){uppytest();DebugMsg("Logging Error: " + e.getMessage());}
		LastSerial = "";
		LastLoc = "";
		LastSensors = "";
		LastNMEA = "";
	}

	public static void GenSerialOutput(){

		long intlat = Math.round(Latitude*600000.0); // decimilliminutes (why? because we know our math works in that)
		long intlon = Math.round(Longitude*600000.0); // decimilliminutes (why? because we know our math works in that) 
		long intalt = Math.round(Altitude*10.0);
		long intcog = Math.round(COG*10.0);
		long intspeed = Math.round(Speed*10.0);
		long inth = Math.round(HeadingOutput);
		long intp = Math.round(PitchOutput);
		long intr = Math.round(RollOutput);

		String serialout = "$PNAV,"+intlat+","+intlon+","+intalt+","+intcog+","+intp+","+intr+","+intspeed+"*";
		if (NMEAOut.equals(serialout) == false)
		{
			NMEAOut = serialout;
			//DebugMsg(NMEAOut);
			//			try {Runtime.getRuntime().exec(new String[]{"sh", "-c",  "echo " + NMEAOut + " > /dev/ttyMSM2"});
			try {Runtime.getRuntime().exec("echo " + NMEAOut + " > /dev/ttyMSM2");
			} catch (IOException e1) {DebugMsg(e1.getMessage());}		
		}


	}
	// method stubs
	public void onAccuracyChanged(Sensor sensor, int accuracy) {}
	public void onProviderDisabled(String provider) {}
	public void onProviderEnabled(String provider) {}
	public void onStatusChanged(String provider, int status, Bundle extras) {}

	// this rounds to 0.1's, 0.01's etc. depending if you give it 10, 100 and so on in "bywhat".
	public static float FlexRound(float roundme, float bywhat) 
	{	return ((float)((int)((roundme+(0.5/bywhat))*bywhat)))/bywhat; 	}

	// This will work if you have angles in degrees. Note the lack of an unholy amount of trig to do it! It averages an array of angles and while we're at it, updates it.
	public static float UpdateAngleArrayReturnAverage (float[] updateme, float newvalue) {
		// get data in
		for( int i = (updateme.length - 1); i > 0; i--) 
			updateme[i] = updateme[i-1];	
		updateme[0] = newvalue;

		// normalize for discontinuity when going from 359.9 to 0.0
		for( int i = 1; i < updateme.length; i++) 
			if ((updateme[0] - updateme[i] > 180) || (updateme[0] - updateme[i] < - 180)) 
				updateme[i] = 360 - updateme[i];

		// average
		float result = 0;
		for( int i = 0; i < updateme.length; i++) 
			result = result + updateme[i];
		result = result / (updateme.length);

		return result;
	}

	//@Override
	public void onSensorChanged(SensorEvent event) {

		if(event.sensor.getType() == Sensor.TYPE_ORIENTATION) {

			// average with older headings
			HeadingOutput = FlexRound(UpdateAngleArrayReturnAverage(Headings, event.values[0]),Roundoff);
			// calculate a delta
			HeadingDelta = FlexRound(Headings[0] - HeadingOutput,Roundoff);

			// average with older pitches
			PitchOutput = FlexRound(UpdateAngleArrayReturnAverage(Pitches, event.values[1]),Roundoff);
			// calculate a delta
			PitchDelta = FlexRound(Pitches[0] - PitchOutput,Roundoff);

			// average with older rolls
			RollOutput = FlexRound(UpdateAngleArrayReturnAverage(Rolls, event.values[2]),Roundoff);
			// calculate a delta
			RollDelta = FlexRound(Rolls[0] - RollOutput,Roundoff);

			String Hstr = Float.toString(HeadingOutput);
			String Pstr = Float.toString(PitchOutput);
			String Rstr = Float.toString(RollOutput);
			// Print
//			txtH.setText("H:  " + Hstr + "\ndH: (" + Float.toString(HeadingDelta)+")");
//			txtP.setText("P:  " + Pstr + "\ndP: (" + Float.toString(PitchDelta)+")");
//			txtR.setText("R:  " + Rstr + "\ndR: (" + Float.toString(RollDelta)+")");

			LastSensors = Hstr +"\t"+ Pstr +"\t"+ Rstr +"\t";

		}

		if(event.sensor.getType() == Sensor.TYPE_ACCELEROMETER) {
			// just print raw

			if (outputserial)
				GenSerialOutput();
//			txtA.setText("Raw\nX=" + Float.toString(event.values[0]) + "\nY=" + Float.toString(event.values[1]) + "\nZ=" + Float.toString(event.values[2]));

			boolean changed = false;

			feedme="";
			String[] com;
			com=new String[4];
			// this is what reads the data.
			try {ct.delete();c0.renameTo(ct);com[0]= new Scanner(ct).useDelimiter("\\Z").next();feedme=feedme+com[0];changed=true;} catch (Exception e1) {com[0]="";}
			try {ct.delete();c1.renameTo(ct);com[1]= new Scanner(ct).useDelimiter("\\Z").next();feedme=feedme+com[1];changed=true;} catch (Exception e1) {com[1]="";}
			try {ct.delete();c2.renameTo(ct);com[2]= new Scanner(ct).useDelimiter("\\Z").next();feedme=feedme+com[2];changed=true;} catch (Exception e1) {com[2]="";}
			try {ct.delete();c3.renameTo(ct);com[3]= new Scanner(ct).useDelimiter("\\Z").next();feedme=feedme+com[3];changed=true;} catch (Exception e1) {com[3]="";}
			
			Log.e("DERP0",com[0]);
			Log.e("DERP1",com[1]);
			Log.e("DERP2",com[2]);
			Log.e("DERP3",com[3]);

			// this happens often enough that we can use it to check against the serial port without setting up a timer.
			if (COMthere)
			{
				try {
					if (serialin.available() > 0)
					{
						feedme = "";
						while (serialin.available() > 0)
						{
							String NMEA = serialin.readLine();
							String[] Parsed = NMEA.split(",");

							if(Parsed[0].equals("$GPGGA")) {
								feedme = feedme + NMEA+"\n";
							}
							else if(Parsed[0].equals("$GPRMC")) {
								feedme = feedme + NMEA+"\n";
							}
							changed = true;
						}
					}
				} catch (Exception e) { feedme = "External serial port not accessible: " + e.toString(); changed = true;}


			}
			
			

			if (changed)
			{
				if (LastSerial == "")
					LastSerial = feedme+"\n";
				else
					LastSerial = LastSerial + feedme + "\n";
				addMessage(feedme,txtSerial);
				//txtSerial.append(feedme);
			}


		}
	}
}