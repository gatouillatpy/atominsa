
import java.net.*;
import java.io.*;

public class AtominsaThread extends Thread
{
	static int HEADER_SERVER = 2001;
	static int HEADER_ONLINE_HOST = 2101;
	static int HEADER_ONLINE_QUIT = 2102;
	static int HEADER_ONLINE_PLAYER = 2201;
	static int HEADER_ONLINE_SCORE = 2301;

	private Socket tSocket;
	
	private PrintWriter tOutput;
	
	private BufferedReader tInput;
	
	private AtominsaMaster tMaster;
	
	private int nThreadID = 0;
	
	private String sRemoteIP;
	
	private AtominsaServer tServer;
	
	public int getID()
	{
		return nThreadID;
	}

	AtominsaThread( Socket _tSocket, AtominsaMaster _tMaster )
	{
		tMaster = _tMaster;
	    
	    tSocket = _tSocket;
	    
	    try
	    {
	    	tOutput = new PrintWriter( tSocket.getOutputStream() );
	      
	    	tInput = new BufferedReader( new InputStreamReader(tSocket.getInputStream()) );
	      
	    	nThreadID = tMaster.addThread( this );
	    }
	    catch ( IOException e )
	    {
			System.out.println( ">> ERROR : " + e.getMessage() );
	    }

	    start();
	}

	public void send( String sMessage )
	{
		tOutput.print( sMessage );
		tOutput.flush();
	}
	
	public void sendServerList()
	{
		String sMessage = "0" + '\36';

		sMessage += String.valueOf( HEADER_SERVER ) + '\36';

		sMessage += String.valueOf( tMaster.getServerCount() ) + '\37';
		
		for ( int k = 0 ; k < tMaster.getServerCount() ; k++ )
		{
			AtominsaServer tServer = tMaster.getServer( k );
			
			sMessage += tServer.sName + ' ' + '[' + String.valueOf(tServer.getPlayerCount()) + ']' + '\37';
			sMessage += tServer.sAddress + '\37';
		}
		
		sMessage += '\4';

		send( sMessage );
	}
	
	private int getIntFromData( String sData, int nIndex )
	{
		int k = -1, n = 0;
		
		String sInt = "";
		
		while ( ++k < sData.length() )
		{
			if ( sData.charAt(k) != '\37' )
			{
				sInt += sData.charAt(k);
			}
			else
			{
				if ( n == nIndex )
					break;
				
				sInt = "";
				
				n++;
			}
		}
		
		return Integer.parseInt( sInt );
	}
	
	private float getFloatFromData( String sData, int nIndex )
	{
		int k = -1, n = 0;
		
		String sFloat = "";
		
		while ( ++k < sData.length() )
		{
			if ( sData.charAt(k) != '\37' )
			{
				sFloat += sData.charAt(k);
			}
			else
			{
				if ( n == nIndex )
					break;
				
				sFloat = "";
				
				n++;
			}
		}
		
		return Float.parseFloat( sFloat );
	}

	private String getStringFromData( String sData, int nIndex )
	{
		int k = -1, n = 0;
		
		String sString = "";
		
		while ( ++k < sData.length() )
		{
			if ( sData.charAt(k) != '\37' )
			{
				sString += sData.charAt(k);
			}
			else
			{
				if ( n == nIndex )
					break;
				
				sString = "";
				
				n++;
			}
		}
		
		return sString;
	}
	
	private void processMessage( int nIndex, int nHeader, String sData )
	{
		if ( nHeader == HEADER_ONLINE_HOST )
		{
			tServer = new AtominsaServer();
			tServer.sAddress = sRemoteIP;
			tServer.sName = getStringFromData( sData, 0 );
			
			tMaster.addServer(tServer);
			
			System.out.println( ">> #" + String.valueOf(nThreadID) + " hosted a game called '" + tServer.sName + "'." );
		}
		else if ( nHeader == HEADER_ONLINE_QUIT )
		{
			tMaster.delServer(tServer);
			
			System.out.println( ">> #" + String.valueOf(nThreadID) + " quitted its hosted game called '" + tServer.sName + "'." );
			
			tServer = null;
		}
		else if ( nHeader == HEADER_ONLINE_PLAYER )
		{
			int nPlayerPosition = getIntFromData( sData, 0 ); // 1..8
			int nPlayerType = getIntFromData( sData, 1 ); // 0 = NIL ; 1 = KB1 ; 2 = KB2 ; 3 = IA
			String sPlayerNickname = getStringFromData( sData, 2 );
			String sPlayerUsername = getStringFromData( sData, 3 );
			String sPlayerPassword = getStringFromData( sData, 4 );
			
			AtominsaPlayer tPlayer = new AtominsaPlayer();

			int k;
			
			for ( k = 0 ; k < tServer.getPlayerCount() ; k++ )
			{
				AtominsaPlayer tTemp = tServer.getPlayer(k);
				
				if ( tTemp.nPosition == nPlayerPosition )
				{
					tPlayer = tTemp;
					
					break;
				}
			}
			
			if ( sPlayerUsername.equalsIgnoreCase("myname") == false && AtominsaDatabase.CheckConnection( sPlayerUsername, sPlayerPassword ) )
			{
				tPlayer = AtominsaDatabase.GetPlayer( sPlayerUsername, sPlayerPassword );
			}
			else
			{
				if ( nPlayerType == 1 ) tPlayer.nState = AtominsaPlayer.STATE_GUEST;
				if ( nPlayerType == 2 ) tPlayer.nState = AtominsaPlayer.STATE_GUEST;
				if ( nPlayerType == 3 ) tPlayer.nState = AtominsaPlayer.STATE_COMPUTER;
				
				tPlayer.sUsername = "null";
				tPlayer.sPassword = "null";
			}	
			
			tPlayer.sNickname = sPlayerNickname;
			
			tPlayer.nPosition = nPlayerPosition;
			
			if ( k >= tServer.getPlayerCount() && nPlayerType > 0 )
			{
				tServer.addPlayer(tPlayer);

				System.out.println( ">> #" + String.valueOf(nThreadID) + " added a new player called '" + tPlayer.sNickname + "'." );
			}
			else if ( k < tServer.getPlayerCount() && nPlayerType == 0 )
			{
				tServer.delPlayer(tPlayer);
				
				System.out.println( ">> #" + String.valueOf(nThreadID) + " deleted a player called '" + tPlayer.sNickname + "'." );
			}
		}
		else if ( nHeader == HEADER_ONLINE_SCORE )
		{
			int nPlayerCount = getIntFromData( sData, 0 ); // 1..8
			
			int l = 1;
			
			for ( int n = 0 ; n < nPlayerCount ; n++ )
			{
				int nPlayerPosition = getIntFromData( sData, l++ );
				int nPlayerScore = getIntFromData( sData, l++ );
				int nPlayerKills = getIntFromData( sData, l++ );
				int nPlayerDeaths = getIntFromData( sData, l++ );
				
				for ( int k = 0 ; k < tServer.getPlayerCount() ; k++ )
				{
					AtominsaPlayer tTemp = tServer.getPlayer(k);
					
					if ( tTemp.nPosition == nPlayerPosition )
					{
						tTemp.fScore += (float)nPlayerScore;
						tTemp.nKills += (float)nPlayerKills;
						tTemp.nDeaths += (float)nPlayerDeaths;
					}
				}
			}
		}
	}
	
	public void run()
	{
		String sMessage = "";
		
		int arg0 = tSocket.getRemoteSocketAddress().toString().indexOf("/") + 1;
		int arg1 = tSocket.getRemoteSocketAddress().toString().indexOf(":");
		sRemoteIP = tSocket.getRemoteSocketAddress().toString().substring(arg0, arg1);

	    System.out.println( ">> #" + String.valueOf(nThreadID) + " connected @" + sRemoteIP + "." );
	    
	    try
	    {
	    	char charCur[] = new char[1];
	    	
	    	while ( tInput.read(charCur, 0, 1) != -1 )
	    	{
	    		if ( charCur[0] != '\4' )
	    		{
	    			sMessage += charCur[0];
	    		}
	    		else
		        {
	    			int k = -1;
	    			
	    			String sIndex = "";
	    			while ( ++k < sMessage.length() )
	    			{
	    				if ( sMessage.charAt(k) != '\36' )
	    				{
	    					sIndex += sMessage.charAt(k);
	    				}
	    				else
	    				{
	    					break;
	    				}
	    			}
	    			int nIndex = Integer.parseInt( sIndex );
		        	
	    			String sHeader = "";
	    			while ( ++k < sMessage.length() )
	    			{
	    				if ( sMessage.charAt(k) != '\36' )
	    				{
	    					sHeader += sMessage.charAt(k);
	    				}
	    				else
	    				{
	    					break;
	    				}
	    			}
	    			int nHeader = Integer.parseInt( sHeader );

	    			String sData = "";
	    			while ( ++k < sMessage.length() )
	    			{
	    				sData += sMessage.charAt(k);
	    			}
	    			
	    			processMessage( nIndex, nHeader, sData );

		        	sMessage = "";
		        }
	    	}
	    }
	    catch ( Exception e )
	    {
			System.out.println( ">> ERROR : " + e.getMessage() );
	    }
	    finally
	    {
			try
			{
			    System.out.println( ">> #" + String.valueOf(nThreadID) + " disconnected." );
			    
			    tMaster.delServer( tServer );
			    
			    tMaster.delThread( this );
				
				tSocket.close();
			}
			catch ( IOException e )
			{
				System.out.println( ">> ERROR : " + e.getMessage() );
			}
	    }
	  }
}
