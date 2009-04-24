
import java.net.*;
import java.util.*;

public class AtominsaMaster
{
	static int ATOMINSA_PORT = 7070;
	
	private ArrayList<AtominsaThread> aThread = new ArrayList<AtominsaThread>();
	
	private ArrayList<AtominsaServer> aServer = new ArrayList<AtominsaServer>();

	private Random tRandom = new Random();

	public static void main( String args[] )
	{
		AtominsaMaster tMaster = new AtominsaMaster();
		
		// DEBUT : JEU D'ESSAI TEMPORAIRE
		/*AtominsaServer tServer0 = new AtominsaServer();
		tServer0.sAddress = "192.168.0.5";
		tServer0.sName = "serveur de test 0";
		tMaster.addServer(tServer0);
		
		AtominsaServer tServer1 = new AtominsaServer();
		tServer1.sAddress = "121.44.12.97";
		tServer1.sName = "serveur de test 1";
		tMaster.addServer(tServer1);
		
		AtominsaServer tServer2 = new AtominsaServer();
		tServer2.sAddress = "84.214.29.117";
		tServer2.sName = "serveur de test 2";
		tMaster.addServer(tServer2);*/
		// FIN : JEU D'ESSAI TEMPORAIRE
		
	    try
	    {
			AtominsaDatabase.Connect();

			new AtominsaConsole( tMaster );
			
			ServerSocket ss = new ServerSocket( ATOMINSA_PORT );
			  
			printWelcome();
			  
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
		System.out.println("บ Latest update : 22/01/2009                       บ");
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
	
	synchronized public void delPlayer( int id )
	{
		for ( int k = 0 ; k < aServer.size() ; k++ )
		{
			AtominsaServer tServer = aServer.get( k );
			
			tServer.delPlayer( id );
		}
	}

	synchronized public ArrayList<AtominsaServer> getPlayableServerList()
	{
		ArrayList<AtominsaServer> list = new ArrayList<AtominsaServer>();
		
		for ( int n = AtominsaServer.PLAYER_LIMIT ; n >= 0 ; n-- )
		{
			for ( int k = 0 ; k < aServer.size() ; k++ )
			{
				AtominsaServer tServer = aServer.get(k);

				if ( tServer.isPlaying() == false && tServer.getPlayerCount() == n )
				{
					list.add( tServer );
				}
			}
		}
		
		return list;
	}

	synchronized public ArrayList<AtominsaServer> getUnplayableServerList()
	{
		ArrayList<AtominsaServer> list = new ArrayList<AtominsaServer>();
		
		for ( int n = AtominsaServer.PLAYER_LIMIT ; n >= 0 ; n-- )
		{
			for ( int k = 0 ; k < aServer.size() ; k++ )
			{
				AtominsaServer tServer = aServer.get(k);

				if ( tServer.isPlaying() == true && tServer.getPlayerCount() == n )
				{
					list.add( tServer );
				}
			}
		}
		
		return list;
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
