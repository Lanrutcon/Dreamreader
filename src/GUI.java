import java.util.Observable;
import java.util.Observer;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.event.*;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.*;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.layout.*;
import javafx.stage.Stage;

public class GUI extends Application implements Observer {

	private Button btn;
	private ProgressBar pb;
	private TextArea text;

	private DatabaseExtractor dbe;

	public GUI() {
		dbe = new DatabaseExtractor();
		dbe.addObserver(this);
	}

	@Override
	public void update(Observable o, Object arg) {
		text.insertText(0, (String) arg + System.lineSeparator());
		pb.setProgress((double) dbe.getCurrentPage() / dbe.getNumberOfPages());
		if (arg.equals("Done!")) {
			Platform.runLater(new Runnable() {
				@Override
				public void run() {
					btn.setText("Database Updated!");
					btn.setDisable(false);
				}
			});
		}
	}

	private void setUpButton() {
		btn = new Button("Update Database");
		btn.setMaxWidth(150);

		btn.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				text.setText("Initializing");
				btn.setText("Updating...");
				btn.setDisable(true);
				dbe.start();
			}
		});
	}

	private void setUpProgressBar() {
		pb = new ProgressBar(0);
		pb.setMaxWidth(250);
	}

	private void setUpTextArea() {
		text = new TextArea();
		text.setEditable(false);
		text.setText("Detailed Log");
	}

	@Override
	public void start(Stage stage) throws Exception {
		Group root = new Group();
		Scene scene = new Scene(root);
		stage.setScene(scene);
		stage.setTitle("Dreamreader Database Extractor");
		stage.getIcons().add(new Image("icon.png"));

		setUpButton();
		setUpProgressBar();
		setUpTextArea();

		BorderPane borderPane = new BorderPane();

		BorderPane.setAlignment(btn, Pos.CENTER);
		BorderPane.setAlignment(text, Pos.CENTER);
		BorderPane.setAlignment(pb, Pos.CENTER);

		BorderPane.setMargin(btn, new Insets(12, 12, 12, 12));
		BorderPane.setMargin(text, new Insets(12, 12, 12, 12));
		BorderPane.setMargin(pb, new Insets(12, 12, 12, 12));

		borderPane.setTop(btn);
		borderPane.setCenter(text);
		borderPane.setBottom(pb);

		scene.setRoot(borderPane);
		stage.show();

	}

	public static void main(String[] args) {
		launch(args);
	}

}
