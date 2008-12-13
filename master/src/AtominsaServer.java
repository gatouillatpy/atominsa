import java.util.ArrayList;


public class AtominsaServer
{
	public String sAddress;
	
	public String sName;
	
	public ArrayList<AtominsaPlayer> aPlayer = new ArrayList<AtominsaPlayer>();
	
	public AtominsaServer()
	{
	}

	synchronized public void delPlayer( AtominsaPlayer tPlayer )
	{
		if ( AtominsaDatabase.CheckConnection( tPlayer.sUsername, tPlayer.sPassword ) )
		{
			AtominsaDatabase.UpdatePlayer( tPlayer );
		}
		
		aPlayer.remove( tPlayer );
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
