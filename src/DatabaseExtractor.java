import java.io.*;
import java.net.*;
import java.util.*;

/**
 * Class DatabaseExtractor represents a database that can extract issues from
 * Bugtracker.
 * 
 * @author Lanrutcon
 *
 */
public class DatabaseExtractor extends Observable {

	// database to store all issues
	private Database db;
	// open issues that contains "quest" in their titles
	private String url = "https://github.com/Atlantiss/BugTracker/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+%5BQuest%5D+in%3Atitle";
	// number of pages, lets assume that has at lease one.
	private int nPages = 1;
	private int currentPage;
	// all source code
	private String sourcePage;

	/**
	 * DatabaseExtractor constructor. Initialize database and gets the number of
	 * pages.
	 * 
	 */
	public DatabaseExtractor() {
		db = new Database();
		getNewUrlSource();
		nPages = extractNumberOfPages();
	}

	private void notifyObserver(Object str) {
		setChanged();
		notifyObservers(str);
	}

	/**
	 * Database getter
	 * 
	 * @return Database
	 * 
	 */
	public Database getDatabase() {
		return db;
	}

	/**
	 * Extract issues from source code and save them into the database. Only
	 * save if they pass the condition.
	 * 
	 */
	public void extractIssues() {
		Scanner s = new Scanner(sourcePage);
		String line = "";
		while (s.hasNextLine()) {
			line = s.nextLine().trim();
			if (Issue.hasGoodTitle(line)) {
				db.addIssue(new Issue(line));
			}
		}
		s.close();
	}

	/**
	 * Save database into a file ("database.lua")
	 * 
	 */
	public void saveDatabaseToFile() {
		PrintWriter pw;
		try {
			pw = new PrintWriter(new File("database.lua"));
			pw.println("--Database of all open reported bugs with \"quest\" filter from Atlantiss Bugtracker--");
			pw.println("--This file was created using the jar file--");
			pw.println("--Do not change this file or the end of the world will come--");
			pw.println("--This file is only used for Dreamreader to check quests--");
			pw.println("");
			pw.println("");
			pw.println("lastUpdate = " + Calendar.getInstance().get(6));
			pw.println("dbIssue = {};");
			for (int i = 0; i < db.getIssueList().size(); i++) {
				pw.println("dbIssue[" + db.getIssueList().get(i).getID() + "] = { \""
						+ db.getIssueList().get(i).getLanguage() + "\", \"" + db.getIssueList().get(i).getZone()
						+ "\", \"" + db.getIssueList().get(i).getName() + "\" };");
			}
			pw.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Sets page
	 * 
	 * @param page
	 *            : int
	 */
	public void setPage(int page) {
		if (getNumberOfPages() >= page)
			url = "https://github.com/Atlantiss/BugTracker/issues?page=" + page
					+ "&q=is%3Aissue+is%3Aopen+quest&utf8=%E2%9C%93";
	}

	/**
	 * Extract number of total pages
	 * 
	 * @return int
	 */
	public int extractNumberOfPages() {
		Scanner s;
		int nPages = 0;
		s = new Scanner(sourcePage);
		String line;
		while (s.hasNextLine()) {
			line = s.nextLine();
			if (line.contains("</a> <a class=\"next_page\"")) {
				// weird way to get the number of pages, but I guess it's
				// working for all cases
				nPages = Integer.parseInt(line.substring(line.indexOf("</a> <a class=\"next_page\"") - 2,
						line.indexOf("</a> <a class=\"next_page\"")));
			}
		}
		s.close();
		return nPages;
	}

	/**
	 * Gets number of pages
	 * 
	 */
	public int getNumberOfPages() {
		return nPages;
	}

	public int getCurrentPage() {
		return currentPage;
	}

	/**
	 * Sets a sourcePage with a source code.
	 * 
	 */
	public void getNewUrlSource() {
		URL site;
		String source = "";
		try {
			site = new URL(url);
			URLConnection conn = site.openConnection();
			BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
			String inputLine;
			while ((inputLine = in.readLine()) != null)
				source += inputLine + System.lineSeparator();
			in.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		sourcePage = source;
	}

	/**
	 * Gets Issues database from "database.lua" file
	 * 
	 * @return Database
	 * 
	 */
	public static Database getIssueDatabase() {
		Scanner sc;
		Database db = new Database();
		try {
			String line, name, zone, lang;
			int id;
			sc = new Scanner(new File("database.lua"));
			while (sc.hasNextLine()) {
				line = sc.nextLine();
				// dbIssue[0] = { "EN", "Loch Modan", "Who's In Charge Here?" };
				if (line.contains("dbIssue[")) {
					id = Integer.parseInt(line.substring(line.indexOf("[") + 1, line.indexOf("]")));
					lang = line.substring(line.indexOf("\"") + 1, line.indexOf("\"") + 3);
					zone = line.substring(line.indexOf(", \"") + 3, line.lastIndexOf(", \"") - 1);
					name = line.substring(line.lastIndexOf(", \"") + 3, line.length() - 4);
					db.addIssue(new Issue(id, lang, name, zone));
				}
			}
			sc.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return db;
	}

	/**
	 * Gets Quest database from "databasQuests.lua" file
	 * 
	 * @return Database
	 */
	public static Database getQuestDatabase() {
		Scanner sc;
		Database db = new Database();
		try {
			String line, name;
			int id;
			sc = new Scanner(new File("databaseQuests.lua"));
			while (sc.hasNextLine()) {
				line = sc.nextLine();
				// db[0] = { "EN", "Loch Modan", "Who's In Charge Here?" };
				if (line.contains("quests[")) {
					id = Integer.parseInt(line.substring(line.indexOf("[") + 1, line.indexOf("]")));
					name = line.substring(line.lastIndexOf(", \"") + 3, line.length() - 4);
					db.addIssue(new Issue(id, "", name, ""));
				}
			}
			sc.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return db;
	}

	/**
	 * Gets Quest database from "qcQuest.lua" file
	 * 
	 * @return Database
	 */
	public static Database getQuestDatabaseFromQC() {
		Scanner sc;
		Database db = new Database();
		boolean v2 = false;
		try {
			String line, name;
			int id;
			sc = new Scanner(new File("qcQuest.lua"));
			while (sc.hasNextLine()) {
				line = sc.nextLine();
				if (line.contains("] = {") && !v2) {
					id = Integer.parseInt(line.substring(line.indexOf("[") + 1, line.indexOf("]")));
					sc.nextLine();
					line = sc.nextLine();
					name = line.trim().substring(1, line.trim().length() - 2);
					db.addIssue(new Issue(id, "", name, ""));
				} else if (line.contains("] = {") && v2) {
					id = Integer.parseInt(line.substring(line.indexOf("[") + 1, line.indexOf("]")));
					sc.nextLine();
					sc.nextLine();
					line = sc.nextLine();
					name = line.trim().substring(1, line.trim().length() - 2);
					db.addIssue(new Issue(id, "", name, ""));
				} else if (line.equals("qcQuestDBv2 = {")) {
					v2 = true;
				}

			}
			sc.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return db;
	}

	public void start() {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					for (int i = 1; i <= getNumberOfPages(); i++) {
						setPage(i);
						getNewUrlSource();
						notifyObserver("Extracting Issues From Page #" + i);
						extractIssues();
						currentPage = i;
						Thread.sleep(100);
					}
				} catch (Exception e) {
					notifyObserver(
							"Warning: Something happened, close and wait a couple of minutes before trying again");
					// e.printStackTrace();
				}
				notifyObserver("Sorting Database");
				Database.joinDatabases(getDatabase(), getQuestDatabase());
				getDatabase().sortByID();
				notifyObserver("Saving Database To File");
				saveDatabaseToFile();
				notifyObserver("Done!");

			}
		}).start();
	}

	/**
	 * Where all begins
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		long start = new Date().getTime();
		DatabaseExtractor dbe = new DatabaseExtractor();
		for (int i = 1; i <= dbe.getNumberOfPages(); i++) {
			dbe.setPage(i);
			dbe.getNewUrlSource();
			dbe.extractIssues();
		}
		Database.joinDatabases(dbe.getDatabase(), getQuestDatabase());
		dbe.getDatabase().sortByID();
		dbe.saveDatabaseToFile();
		System.out.println("Time Elapsed: " + (new Date().getTime() - start));
	}

}
