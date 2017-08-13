package networking;

import java.io.Serializable;

public abstract class Message implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String name;
	
	public Message(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}

}
