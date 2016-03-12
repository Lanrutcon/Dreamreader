import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.*;

/**
 * Class Database represents a database of issues.
 * 
 * @author Lanrutcon
 *
 */
public class Database {

	//an array to store all issues
	private ArrayList<Issue> issueList;

	/**
	 * Database constructor that initialize the array.
	 * 
	 */
	public Database() {
		issueList = new ArrayList<Issue>();
	}

	/**
	 * ArrayList getter.
	 * 
	 * @return ArrayList
	 * 
	 */
	public ArrayList<Issue> getIssueList() {
		return issueList;
	}

	/**
	 * Add issue e to the database.
	 * 
	 * @param Issue e: Issue to be added
	 *
	 */
	public void addIssue(Issue e) {
		issueList.add(e);
	}

	/**
	 * Save database into a file
	 * 
	 * @param fileName : String
	 */
	public void toFile(String fileName) {
		PrintWriter pw;
		try {
			pw = new PrintWriter(new File(fileName));
			pw.println("quests = {};");
			for (int i = 0; i < getIssueList().size(); i++) {
				pw.println("quests[" + getIssueList().get(i).getID()
						+ "] = { \"" + getIssueList().get(i).getName()
						+ "\" };");
			}
			pw.close();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * Sort arraylist by ID (e.g.: 1,4,5,7,200, etc)
	 * 
	 */
	public void sortByID() {
		boolean changed = true;
		Issue e;
		while (changed) {
			changed = false;
			for (int i = 0; i < issueList.size() - 1; i++) {
				if (issueList.get(i).getID() > issueList.get(i + 1).getID()) {
					e = issueList.get(i + 1);
					issueList.set(i + 1, issueList.get(i));
					issueList.set(i, e);
					changed = true;
				}
			}
		}
	}
	
	/**
	 * Delete issues that have the same ID.
	 * 
	 */
	public void deleteDuplicatedIssues() {
		ArrayList<Issue> checker = this.issueList;
		for (int i = 0; i < issueList.size(); i++) {
			for (int j = 0; j < checker.size(); j++) {
				if (i != j
						&& issueList.get(i).getID() == checker.get(j).getID())
					issueList.remove(i + 1);
			}
		}
	}


	/**
	 * "Merge" Database b into Database a.
	 * If both databases have issues with the same name, Database b will give the ID to Database a.
	 *	
	 * @param a : Database 
	 * @param b : Database
	 */
	public static void joinDatabases(Database a, Database b) {
		for (int i = 0; i < a.getIssueList().size(); i++) {
			for (int j = 0; j < b.getIssueList().size(); j++) {
				if (a.getIssueList().get(i).hasSameName(b.getIssueList().get(j))) {
					a.getIssueList().get(i).setID(b.getIssueList().get(j).getID());
					break; // no more search
				}
			}
		}
	}
}
