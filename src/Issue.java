/**
 * Class Issue represents an issue in Github (Bugtracker).
 * 
 * @author Lanrutcon
 *
 */

public class Issue {

	/** an id for every issue - will be quest id later */
	private int id;
	/** language of the issue, English or Polish */
	private String language;
	/** issue last argument, quest name */
	private String name;
	/** quest zone */
	private String zone;

	/**
	 * Issue constructor that receives 3 Strings as arguments.
	 * 
	 * @param language
	 * @param name
	 * @param zone
	 */
	public Issue(int id, String language, String name, String zone) {
		//name = name.replaceAll("&#39;", "'").replaceAll("&quot;", "\\\\\"");	//html code might change symbols
		this.id = id;
		this.language = language;
		this.name = name;
		this.zone = zone;
	}

	/**
	 * Issue constructor that receives a String as argument. Example:
	 * [PL][Quest][The Slave Pens] Lost in action
	 * 
	 * @param line
	 */
	public Issue(String line) {
		line = line.replaceAll("&#39;", "'").replaceAll("&quot;", "\\\\\"");	//html code might change symbols
		this.id = -1;
		language = line.substring(1, 3);
		name = line.substring(line.lastIndexOf("]") + 1, line.length()).trim();
		zone = line.substring(line.lastIndexOf("[") + 1, line.lastIndexOf("]"));
	}

	/**
	 * Checks the title. Should be used before Issue(String line).
	 * 
	 * @param line : String
	 * @return true if everything is OK
	 */
	public static boolean hasGoodTitle(String line) {
		//line = line.replaceAll("&#39;", "'");
		if (line.length() < 12)
			return false;
		
		if (!line.substring(0, 4).equals("[EN]")
				&& !line.substring(0, 4).equals("[PL]")) {
			//System.out.println("Bad Language");
			return false;
		}
		if (!line.substring(4, 11).equals("[Quest]")) {
			//System.out.println("Bad quest section");
			return false;
		}
		if (!line.substring(11, 12).equals("[") || line.lastIndexOf("]") == 13) {
			//System.out.println("Bad zone");
			return false;
		}
		if (line.substring(line.lastIndexOf("]") + 1, line.length()).trim()
				.equals("")) {
			//System.out.println("Bad quest name");
			return false;
		}

		return true;
	}

	/**
	 * @return the id
	 */
	public int getID() {
		return id;
	}

	/**
	 * @return the language
	 */
	public String getLanguage() {
		return language;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @return the zone
	 */
	public String getZone() {
		return zone;
	}

	public void setID(int id) {
		this.id = id;
	}

	/**
	 * Compares with another Issue.
	 * 
	 * @param i
	 * @return true if they are equal.
	 */
	public boolean equals(Issue i) {
		if (name.equalsIgnoreCase(i.getName())
				&& !zone.equalsIgnoreCase(i.getZone()))
			System.out
					.println("Warning: Names are equals but zones are different");
		else if (name.equalsIgnoreCase(i.getName())
				&& zone.equalsIgnoreCase(i.getZone())) {
			System.out.println("Both name and zones are equal");
			return true;
		}
		return false;
	}
	
	public boolean hasSameName(Issue i){
		if(name.equals("") || i.getName().equals(""))
			return false;
		if(name.equals(i.getName()))
			return true;
		if(name.equalsIgnoreCase(i.getName()))
			return true;
		if(name.contains(i.getName()) || i.getName().contains(name))
			return true;
		if(name.toLowerCase().contains(i.getName().toLowerCase()) || i.getName().toLowerCase().contains(name.toLowerCase()))
			return true;
		return false;
	}

	@Override
	public String toString() {
		return "[" + language + "][Quest][" + zone + "] " + name;
	}

}
