package re.propbridge;
// outputs to log, inputs from file. this is the most reliable combination found so far.
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

import android.util.Log;

public class IO_propbridge {
	public static 	File checkthisfile;
	public static final String logtag_i = "iPBRo";
	public static final String logtag_o = "iPBRo"; // cool story pbro
	public static String logpath = "";

	static public boolean init(String fileposition)
	{
		logpath = "/"+fileposition+"/"+logtag_o;
		logpath = logpath.replace("//", "/");
		checkthisfile = new File(logpath);
		Log.e(logtag_i,logpath);
		return true; // TODO add filesystem check, send out a message to the board saying where the file actually is

	}
	static public void send(String str)
	{
		Log.e(logtag_i,str); // e because as per ADB specs it enjoys less latency
	}
	static public String receive()
	{
		try
		{
			StringBuffer fileData = new StringBuffer(1024);
			BufferedReader reader = new BufferedReader(new FileReader(checkthisfile),1024);
			char[] buf = new char[1024];
			int numRead=0;
			while((numRead=reader.read(buf)) != -1){
				String readData = String.valueOf(buf, 0, numRead);
				fileData.append(readData);
				buf = new char[1024];
			}
			reader.close();

			FileWriter deleter = new FileWriter(checkthisfile);
			deleter.write("");
			deleter.flush();

			return fileData.toString();
		}
		catch(Exception e) {e.printStackTrace();return "";}
	}
	static public long available()
	{
		try
		{
			return checkthisfile.length();
		}
		catch(Exception e) {return 0;}
	}
}
