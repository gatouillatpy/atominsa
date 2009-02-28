
import java.net.*;
import java.util.ArrayList;
import java.io.*;

public class AtominsaThread extends Thread
{
	static int HEADER_SERVER = 2001;
	static int HEADER_ONLINE_HOST = 2101;
	static int HEADER_ONLINE_QUIT = 2102;
	static int HEADER_ONLINE_PLAYER = 2201;
	static int HEADER_ONLINE_SCORE = 2301;
	static int HEADER_ONLINE_BEGIN_GAME = 2401;
	static int HEADER_ONLINE_END_GAME = 2402;

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
		
		// envoi de la liste des serveurs dont la partie n'est pas encore commencée
		{
			ArrayList<AtominsaServer> list = tMaster.getPlayableServerList();
	
			sMessage += String.valueOf( list.size() ) + '\37';

			for ( int k = 0 ; k < list.size() ; k++ )
			{
				AtominsaServer tServer = list.get(k);
				
				sMessage += tServer.sName + '\37';
				sMessage += tServer.sAddress + '\37';
				sMessage += String.valueOf(tServer.nPort) + '\37';
				sMessage += String.valueOf(tServer.getPlayerCount()) + '\37';
			}
		}

		// envoi de la liste des serveurs dont la partie est pas commencée
		{
			ArrayList<AtominsaServer> list = tMaster.getUnplayableServerList();
	
			sMessage += String.valueOf( list.size() ) + '\37';

			for ( int k = 0 ; k < list.size() ; k++ )
			{
				AtominsaServer tServer = list.get(k);
				
				sMessage += tServer.sName + '\37';
				sMessage += tServer.sAddress + '\37';
				sMessage += String.valueOf(tServer.nPort) + '\37';
				sMessage += String.valueOf(tServer.getPlayerCount()) + '\37';
			}
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
			tServer.sAddress = getStringFromData( sData, 0 );
			tServer.nPort = getIntFromData( sData, 1 );
			tServer.sName = getStringFromData( sData, 2 );
			
			tMaster.addServer(tServer);
			
			System.out.println( ">> #" + String.valueOf(nThreadID) + " hosted a game called '" + tServer.sName + "' @" + tServer.sAddress + ":" + String.valueOf(tServer.nPort) + "." );
		}
		else if ( nHeader == HEADER_ONLINE_QUIT )
		{
			tServer.updatePlayers();
			
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
			
			int nPlayerPosition[] = new int[nPlayerCount];
			int nPlayerScore[] = new int[nPlayerCount];
			int nPlayerKills[] = new int[nPlayerCount];
			int nPlayerDeaths[] = new int[nPlayerCount];

			for ( int n = 0 ; n < nPlayerCount ; n++ )
			{
				nPlayerPosition[n] = getIntFromData( sData, l++ );
				nPlayerScore[n] = getIntFromData( sData, l++ );
				nPlayerKills[n] = getIntFromData( sData, l++ );
				nPlayerDeaths[n] = getIntFromData( sData, l++ );
			}
			
			// calcul du nombre de points gagnés
			
			for ( int n = 0 ; n < nPlayerCount ; n++ )
			{
				for ( int k = 0 ; k < tServer.getPlayerCount() ; k++ )
				{
					AtominsaPlayer tPlayer = tServer.getPlayer(k);
					
					if ( tPlayer.nState != AtominsaPlayer.STATE_SOLDIER ) continue;
					
					if ( tPlayer.nPosition == nPlayerPosition[n] )
					{
						tPlayer.nScore += nPlayerScore[n];
						tPlayer.nTotal += 1;
						tPlayer.nKills += nPlayerKills[n];
						tPlayer.nDeaths += nPlayerDeaths[n];

						// calcul du nombre de points gagnés

						for ( int m = 0 ; m < tServer.getPlayerCount() ; m++ )
						{
							AtominsaPlayer tOther = tServer.getPlayer(m);
							
							if ( tOther.nState != AtominsaPlayer.STATE_SOLDIER ) continue;

							if ( tOther != tPlayer )
							{
								float ratio = tOther.fPoints / tPlayer.fPoints;
								
								if ( ratio <= 8.0f )
								{
									tPlayer.fPoints += 4.0f * nPlayerScore[n] * Math.pow( ratio, 2.0 );
									
									int count = nPlayerKills[n] - nPlayerDeaths[n];
									
									if ( count > 0 )
										tPlayer.fPoints += count * Math.pow( ratio, 2.0 );
								}
								else
								{
									tPlayer.fPoints += 4.0f * nPlayerScore[n] * 8.0f * ratio;
									
									int count = nPlayerKills[n] - nPlayerDeaths[n];
									
									if ( count > 0 )
										tPlayer.fPoints += count * 8.0f * ratio;
								}
							}
						}
					}
				}
			}
		}
		else if ( nHeader == HEADER_ONLINE_BEGIN_GAME )
		{
			System.out.println( ">> #" + String.valueOf(nThreadID) + " begun its game." );
			
			tServer.beginGame();
		}
		else if ( nHeader == HEADER_ONLINE_END_GAME )
		{
			if ( tServer.isPlaying() )
				System.out.println( ">> #" + String.valueOf(nThreadID) + " ended its game." );
			
			tServer.endGame();
		}
	}
	
	public void run()
	{
		String sMessage = "";
		
		int arg0 = tSocket.getRemoteSocketAddress().toString().indexOf("/") + 1;
		int arg1 = tSocket.getRemoteSocketAddress().toString().indexOf(":");
		sRemoteIP = tSocket.getRemoteSocketAddress().toString().substring(arg0, arg1);

	    System.out.println( ">> #" + String.valueOf(nThreadID) + " connected." );
	    
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
			    
			    if ( tServer != null )
			    	tServer.updatePlayers();
			    
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
