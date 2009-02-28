import java.util.ArrayList;


public class AtominsaServer
{
	public static int PLAYER_LIMIT = 8;
	
	public String sAddress;
	
	public int nPort;
	
	public String sName;
	
	public ArrayList<AtominsaPlayer> aPlayer = new ArrayList<AtominsaPlayer>();
	
	public Boolean bPlaying;
	
	public AtominsaServer()
	{
		bPlaying = false;
	}

	synchronized public void beginGame()
	{
		bPlaying = true;
	}

	synchronized public void endGame()
	{
		bPlaying = false;
	}

	synchronized public Boolean isPlaying()
	{
		return bPlaying;
	}

	synchronized public void delPlayer( AtominsaPlayer tPlayer )
	{
		if ( AtominsaDatabase.CheckConnection( tPlayer.sUsername, tPlayer.sPassword ) )
		{
			AtominsaDatabase.UpdatePlayer( tPlayer );
		}
		
		aPlayer.remove( tPlayer );
	}

	synchronized public void updatePlayers()
	{
		for ( int k = 0 ; k < aPlayer.size() ; k++ )
		{
			AtominsaPlayer tPlayer = aPlayer.get(k);
			
			if ( tPlayer != null )
			{
				if ( AtominsaDatabase.CheckConnection( tPlayer.sUsername, tPlayer.sPassword ) )
				{
					AtominsaDatabase.UpdatePlayer( tPlayer );
				}
			}
		}
	}

	synchronized public void addPlayer( AtominsaPlayer tPlayer )
	{
		aPlayer.add( tPlayer );
	}
	
	synchronized public AtominsaPlayer getPlayer( int k )
	{
		return aPlayer.get( k );
	}
	
	synchronized public int getPlayerCount()
	{
		return aPlayer.size();
	}
}
