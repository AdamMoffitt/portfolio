package music;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import logic.Song;

public class JsonReader {

	private static String readAll(Reader rd) throws IOException {
		StringBuilder sb = new StringBuilder();
		int cp;
		while ((cp = rd.read()) != -1) {
			sb.append((char) cp);
		}
		return sb.toString();
	}

	public static JSONObject readJsonFromUrl(String urlString) throws IOException, JSONException {
		URL url = new URL(urlString);
		URLConnection conn = url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestProperty("Authentication",
				"Basic ZWUzNzYxZDUzNmVmNDBkMGIwZTA5NmE0MmFmZGVmYzA6ZDViYmQ0MjczMDk2NDVjYjkxYzM3ZjA1OTM0NTc0OTk=");
		Map<String, List<String>> m = conn.getHeaderFields();
		System.out.println(m.toString());

		InputStream is = conn.getInputStream();
		try {
			BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
			String jsonText = readAll(rd);
			JSONObject json = new JSONObject(jsonText);
			return json;
		} finally {
			is.close();
		}
	}

	public static ArrayList<SongData> getSongData(String songString) {

		// Convert string into char array, and change and spaces to +
		char[] tempSongChars = songString.toCharArray();
		for (int i = 0; i < tempSongChars.length; i++) {
			if (tempSongChars[i] == ' ') {
				tempSongChars[i] = '+';
			}
		}
		songString = String.valueOf(tempSongChars);

		try {
			JSONObject json = readJsonFromUrl("https://api.spotify.com/v1/search?q=" + songString + "&type=track");

			JSONObject ar = (JSONObject) json.get("tracks");

			JSONArray ar1 = (JSONArray) ar.get("items");

			ArrayList<SongData> results = new ArrayList<SongData>();

			for (int i = 0; i < ar1.length(); i++) {
				JSONObject item = (JSONObject) ar1.get(i);
				String songName = item.get("name").toString();
				String previewURL = item.get("preview_url").toString();
				String songID = item.get("id").toString();
				JSONObject album = (JSONObject) item.get("album");
				JSONArray image = (JSONArray) album.get("images");
				String imageURL = (String) ((JSONObject) (image.get(1))).get("url");
				JSONArray artist = (JSONArray) item.get("artists");
				String artistName = (String) ((JSONObject) (artist.get(0))).get("name");
				SongData newSong = new SongData(songName, artistName, songID, imageURL, previewURL);
				results.add(newSong);

				System.out.println();
				System.out.println(item.get("name").toString());
				System.out.println(item.get("preview_url").toString());
				System.out.println(item.get("id").toString());
				System.out.println(((JSONObject) (image.get(1))).get("url"));
				System.out.println(((JSONObject) (artist.get(0))).get("name"));
				System.out.println();
			}
			System.out.println("************************************************");
			return results;
		} catch (Exception e) {
			System.out.println("Invalid entry. Choose another song");
			return null;
		}
	}

	public static void main(String[] args) throws IOException, JSONException {
		System.out.println("Enter a song: ");
		Scanner s = new Scanner(System.in);
		String song = s.nextLine();
		try {
			JSONObject json = readJsonFromUrl("https://api.spotify.com/v1/search?q=" + song + "&type=track");
			// System.out.println(json.toString());
			// System.out.println(" ");
			// System.out.println(" ");

			JSONObject ar = (JSONObject) json.get("tracks");

			JSONArray ar1 = (JSONArray) ar.get("items");
			// System.out.println("***" + ar1.toString());
			// System.out.println(ar1.get(0).toString());
			// System.out.println(ar1.get(1).toString());
			// System.out.println(ar1.get(2).toString());

			ArrayList<SongData> results = new ArrayList<SongData>();

			for (int i = 0; i < ar1.length(); i++) {
				JSONObject item = (JSONObject) ar1.get(i);
				String songName = item.get("name").toString();
				String previewURL = item.get("preview_url").toString();
				String songID = item.get("id").toString();
				JSONObject album = (JSONObject) item.get("album");
				JSONArray image = (JSONArray) album.get("images");
				String imageURL = (String) ((JSONObject) (image.get(1))).get("url");
				JSONArray artist = (JSONArray) item.get("artists");
				String artistName = (String) ((JSONObject) (artist.get(0))).get("name");
				SongData newSong = new SongData(songName, artistName, songID, imageURL, previewURL);
				results.add(newSong);

				System.out.println();
				System.out.println(item.get("name").toString());
				System.out.println(item.get("preview_url").toString());
				System.out.println(item.get("id").toString());
				System.out.println(((JSONObject) (image.get(1))).get("url"));
				System.out.println(((JSONObject) (artist.get(0))).get("name"));
				System.out.println();
			}

			System.out.println("************************************************");
			// JSONObject ar2 = (JSONObject)ar1.get(1);
			// System.out.println(ar2.get(""));
			// JSONArray ar3 = (JSONArray)ar2.get("artists");
			//
			// for (int i = 0; i < ar3.length(); i++){
			// JSONObject ar4 = (JSONObject)ar3.get(i);
			//
			// String artist = (String)ar4.get("name");
			// String id = (String)ar4.get("id");
			// //results.
			//
			// }
			//
			// JSONObject ar4 = (JSONObject)ar3.get(0);
			//
			// String songName = (String)ar4.get("name");
			// String songId = (String)ar4.get("id");
			// System.out.println(ar3.get(0));
			// System.out.println(ar3.get(1));
			// System.out.println(ar3.get(2));

		} catch (Exception e) {
			System.out.println("Invalid entry. Choose another song");
		}

		// JFrame temp = new JFrame();
		// JFXPanel jfx = new JFXPanel();
		// BorderPane borderPane = new BorderPane();
		// WebView webComponent = new WebView();
		// borderPane.setCenter(webComponent);
		// Scene scene = new Scene(borderPane,450,450);
		// jfx.setScene(scene);
		//
		//
		// webComponent.getEngine().load("http://google.com/");
		// temp.setSize(600,600);
		// temp.add(jfx);
		// temp.setVisible(true);

		// JTextArea jta = new JTextArea("<html> <iframe
		// src="https://embed.spotify.com/?uri=spotify:user:spotify:playlist:3rgsDhGHZxZ9sB9DQWQfuf"
		// width="300" height="380" frameborder="0"
		// allowtransparency="true"></iframe></html>");
	}

}