
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.GregorianCalendar;
import java.util.Random;

public class AtominsaDatabase
{
	static private Random tRandom = new Random();
	static private GregorianCalendar tCalendar = new GregorianCalendar();
	
	static private Connection con;

    static public boolean Connect()
    {
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			
			con = DriverManager.getConnection( "jdbc:mysql://localhost:3306/atominsa", "root", "" );
	    }
		catch ( SQLException e )
		{
			return false;
		}
		catch ( ClassNotFoundException e )
		{
			return false;
		}

		return true;
    }    
    
    static public void Disconnect()
    {
		try
		{
	        con.close();
	    }
		catch ( SQLException e )
		{
		}
    }

    static public AtominsaPlayer GetPlayer( String _sUsername, String _sPassword )
    {
        String query = "SELECT * FROM player WHERE ";
        query += "username = '" + _sUsername + "' AND ";
        query += "password = '" + _sPassword + "'";
        
		try
		{
	        Statement statement = con.createStatement();
	        ResultSet result = statement.executeQuery(query);
	        
	        result.next();
	        
	        AtominsaPlayer tPlayer = new AtominsaPlayer();
	        
	        tPlayer.nID = result.getInt("id");
	        
	        tPlayer.sNickname = result.getString("nickname");
	        
	        tPlayer.sUsername = result.getString("username");
	        tPlayer.sPassword = result.getString("password");
	        
	        tPlayer.nCountry = result.getInt("country");
	        tPlayer.nRegion = result.getInt("region");
	        tPlayer.nDepartment = result.getInt("department");
	        
	        tPlayer.fPoints = result.getFloat("points");

	        tPlayer.sEmail = result.getString("email");
	        
	        tPlayer.nState = result.getInt("state");
	        
	        tPlayer.nKills = result.getInt("kill");
	        tPlayer.nDeaths = result.getInt("death");

	        tPlayer.nScore = result.getInt("score");
	        tPlayer.nTotal = result.getInt("total");

	        result.close();
	        statement.close();

	        return tPlayer;
		}
		catch ( SQLException e )
		{
			return null;
		}
    }
    
    static public boolean CheckUsername( String _sUsername )
    {
        boolean bResult;
        
        String query = "SELECT * FROM player WHERE ";
        query += "username = '" + _sUsername + "'";
        
		try
		{
	        Statement statement = con.createStatement();
	        ResultSet result = statement.executeQuery(query);
	            
	        result.next();
	        
	        if ( result.getInt("id") != 0 ) bResult = true; else bResult = false;
	
	        result.close();
	        statement.close();
	    }
		catch ( SQLException e )
		{
			return false;
		}
		
        return bResult;
    }
    
    static public boolean CheckConnection( String _sUsername, String _sPassword )
    {
        boolean bResult;
        
        String query = "SELECT * FROM player WHERE ";
        query += "username = '" + _sUsername + "' AND ";
        query += "password = '" + _sPassword + "'";
        
		try
		{
	        Statement statement = con.createStatement();
	        ResultSet result = statement.executeQuery(query);
	            
	        result.next();
	        
	        if ( result.getInt("id") != 0 ) bResult = true; else bResult = false;
	
	        result.close();
	        statement.close();
	    }
		catch ( SQLException e )
		{
			return false;
		}

        return bResult;
    }
    
    static public boolean AddPlayer( String _sUsername, String _sPassword )
    {
        AtominsaPlayer tPlayer = new AtominsaPlayer();
        
        tPlayer.nID = tRandom.nextInt(1073741824);
        
        tPlayer.sNickname = "Atominsa Player";
        
        tPlayer.sUsername = _sUsername;
        tPlayer.sPassword = _sPassword;
        
        tPlayer.nCountry = 0; 
        tPlayer.nRegion = 0;
        tPlayer.nDepartment = 0;
        
        tPlayer.fPoints = 999.999f;

        tPlayer.sEmail = "player@atominsa.com";
        
        tPlayer.nState = AtominsaPlayer.STATE_MEMBER;
   	
        tPlayer.nKills = 0;
        tPlayer.nDeaths = 0;

        tPlayer.nScore = 0;
        tPlayer.nTotal = 0;

        String query = "INSERT INTO player (id, nickname, username, password, country, region, department, points, email, state, kill, death, score, total) VALUES (";
        query += String.valueOf(tPlayer.nID) + ", ";
        query += "'" + String.valueOf(tPlayer.sNickname) + "', ";
        query += "'" + String.valueOf(tPlayer.sUsername) + "', ";
        query += "'" + String.valueOf(tPlayer.sPassword) + "', ";
        query += String.valueOf(tPlayer.nCountry) + ", ";
        query += String.valueOf(tPlayer.nRegion) + ", ";
        query += String.valueOf(tPlayer.nDepartment) + ", ";
        query += String.valueOf(tPlayer.fPoints) + ", ";
        query += "'" + String.valueOf(tPlayer.sEmail) + "', ";
        query += String.valueOf(tPlayer.nState) + ", ";
        query += String.valueOf(tPlayer.nKills) + ", ";
        query += String.valueOf(tPlayer.nDeaths) + ", ";
        query += String.valueOf(tPlayer.nScore) + ", ";
        query += String.valueOf(tPlayer.nTotal) + ")";
        
		try
		{
	        Statement statement = con.createStatement();
	        statement.executeUpdate(query);
	
	        statement.close();
	    }
		catch ( SQLException e )
		{
			return false;
		}
		
        return true;
    }
    
    static public boolean UpdatePlayer( AtominsaPlayer _tPlayer )
    {
        String query = "UPDATE player SET ";
        query += "`nickname`='" + String.valueOf(_tPlayer.sNickname) + "', ";
        query += "`points`='" + String.valueOf(_tPlayer.fPoints) + "', ";
        query += "`state`=" + String.valueOf(_tPlayer.nState) + ", ";
        query += "`kill`=" + String.valueOf(_tPlayer.nKills) + ", ";
        query += "`death`=" + String.valueOf(_tPlayer.nDeaths) + ", ";
        query += "`score`=" + String.valueOf(_tPlayer.nScore) + ", ";
        query += "`total`=" + String.valueOf(_tPlayer.nTotal) + " ";
        query += "WHERE `id`=" + String.valueOf(_tPlayer.nID) + "";
        
		try
		{
	        Statement statement = con.createStatement();
	        statement.executeUpdate(query);
	
	        statement.close();
	    }
		catch ( SQLException e )
		{
			return false;
		}
		
        return true;
    }
}