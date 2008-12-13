
import java.net.*;
import java.io.*;
import java.util.*;

public class AtominsaMaster
{
	static int ATOMINSA_PORT = 443;
	
	private ArrayList<AtominsaThread> aThread = new ArrayList<AtominsaThread>();
	
	private ArrayList<AtominsaServer> aServer = new ArrayList<AtominsaServer>();

	private Random tRandom = new Random();

	public static void main( String args[] )
	{
		AtominsaMaster tMaster = new AtominsaMaster();
		
	    try
	    {
			new AtominsaConsole( tMaster );
			
			ServerSocket ss = new ServerSocket( ATOMINSA_PORT );
			  
			printWelcome();
			
			AtominsaDatabase.Connect();
			  
			while ( true )
			{
				new AtominsaThread( ss.accept(), tMaster );
			}
	    }
	    catch ( Exception e )
	    {
			System.out.println( ">> ERROR : " + e.getMessage() );
	    }
	}

	static private void printWelcome()
	{
		System.out.println("ษออออออออออออออออออออออออออออออออออออออออออออออออออป");
		System.out.println("บ            Atominsa Master Server                บ");
		System.out.println("ฬออออออออออออออออออออออออออออออออออออออออออออออออออน");
		System.out.println("บ Latest update : 13/12/2008                       บ");
		System.out.println("ศออออออออออออออออออออออออออออออออออออออออออออออออออผ");
	}

	synchronized public void sendAll( String sMessage )
	{
		for ( int k = 0 ; k < aThread.size() ; k++ )
		{
			AtominsaThread tThread = aThread.get(k);

			tThread.send( sMessage );
		}
	}

	synchronized public void delServer( AtominsaServer tServer )
	{
		aServer.remove( tServer );
	}

	synchronized public int addServer( AtominsaServer tServer )
	{
		aServer.add( tServer );
		
		return tRandom.nextInt(1073741824);
	}
	
	synchronized public AtominsaServer getServer( int k )
	{
		return aServer.get( k );
	}
	
	synchronized public int getServerCount()
	{
		return aServer.size();
	}
	
	synchronized public void delThread( AtominsaThread tThread )
	{
		aThread.remove( tThread );
	}

	synchronized public int addThread( AtominsaThread tThread )
	{
		aThread.add( tThread );
		
		tThread.sendServerList();
		
		return tRandom.nextInt(1073741824);
	}

	synchronized public int getThreadCount()
	{
		return aThread.size();
	}
}
