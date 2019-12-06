/* LICENSE: You can do whatever you want with this, on four conditions.
 * 1) Share and share alike. This means source, too.
 * 2) Acknowledge attribution to spiritplumber@gmail.com in your code.
 * 3) Email me to tell me what you're doing with this code! I love to know people are doing cool stuff!
 * 4) You may NOT use this code in any sort of weapon.
 */

package re.propbridge;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.Menu;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class propbridge extends Activity {

	static public final char cr = (char) 13; // because i don't want to type that in every time
	static public final char lf = (char) 10; // because i don't want to type that in every time
	static EditText editbox;
	static EditText cmdbox;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		
		IO_propbridge.init("sqlite_stmt_journals");

		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

		editbox = (EditText) findViewById(R.id.EditText01);
		cmdbox = (EditText) findViewById(R.id.EditText02);
		final Button savebutton = (Button) findViewById(R.id.Button01 );
		cmdbox.setText("www.f3.to");
		editbox.setText("");
		IO_propbridge.send(cmdbox.getText().toString()+"\r\n");
		savebutton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				IO_propbridge.send(cmdbox.getText().toString()+"\r\n");
				cmdbox.setText("");
				editbox.setText(IO_propbridge.receive());
			}
		});
		
		//NAVCOMCLoop(14000);
	}

	static public final void NAVCOMCLoop(final long setevery) {
		new CountDownTimer(setevery, 250) {
			public final void onTick(long millisUntilFinished) {
				
				IO_propbridge.send(cmdbox.getText().toString());
				cmdbox.setText("");
				editbox.setText(editbox.getText()+IO_propbridge.receive());

				//RobotClient.msghandler.sendEmptyMessage(3); // slightly better frame rate, but causes much higher power consumption (enough to defeat a charger)
			}
			public final void onFinish() {
				NAVCOMCLoop(setevery);
			}
		}.start();
	}

	public boolean onCreateOptionsMenu(Menu menu) {
		// these show up in the primary screen: out of order for display reasons
		menu.add(0, 0, 0, "EXITING");
		return true;
	}
	public boolean onPrepareOptionsMenu(Menu menu) {
		android.os.Process.killProcess(android.os.Process.myPid());
		return true;
	}


}

