
public class AtominsaPlayer
{
	static public int STATE_UNKNOWN = 0; // peu probable
	static public int STATE_COMPUTER = 1; // ia temporaire
	static public int STATE_GUEST = 2; // joueur temporaire
	static public int STATE_MEMBER = 3; // joueur inscrit mais n'ayant pas validé son inscription par email
	static public int STATE_SOLDIER = 4; // joueur définitivement inscrit
	static public int STATE_DEAD = 5; // joueur banni
	
	public int nPosition;

	public String sNickname;

	public String sUsername;
	public String sPassword;

	public int nID;
	
	public int nCountry;
	public int nRegion;
	public int nDepartment;
	
	public int nScore; // nb de parties gagnées
	public int nTotal; // nb de parties jouées
	
	public float fPoints;

	public int nKills;
	public int nDeaths;
	
	public String sEmail;
	
	public int nState;
}
