package networking;

public class StringMessage extends Message{
	
	private String content;

	public StringMessage(String name, String content) {
		super(name);
		this.content = content;
	}
	
	public String getContent() {
		return content;
	}

}
