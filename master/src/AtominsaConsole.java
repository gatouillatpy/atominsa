
import java.io.*;

public class AtominsaConsole extends Thread
{
	AtominsaMaster tMaster;
	
	BufferedReader tInput;
	
	String sCommand = "";

	AtominsaConsole( AtominsaMaster _tMaster )
	{
		tMaster = _tMaster;

		tInput = new BufferedReader( new InputStreamReader(System.in) );

		start();
	}

	public void run()
	{
		try
		{
			while ( (sCommand = tInput.readLine()) != null )
			{
				if ( sCommand.equalsIgnoreCase("quit") )
				{
					AtominsaDatabase.Disconnect();

					System.exit(0);
				}
				else if ( sCommand.equalsIgnoreCase("list") )
				{
					System.out.println( ">> Listing connected users (" + String.valueOf(tMaster.getThreadCount()) + ") :");
				}
				else if ( sCommand.equalsIgnoreCase("help") )
				{
					System.out.println( ">> Listing known commands :" );
					System.out.println( ">> - list : to show the connected users list" );
					System.out.println( ">> - quit : to quit" );
					System.out.println( ">> - help : to show this help" );
				}
				else
				{
					System.out.println( ">> Unknown command " + sCommand + "." );
				}
				System.out.flush();
			}
		}
		catch ( IOException e )
		{
			System.out.println( ">> ERROR : " + e.getMessage() );
		}
	}
}
