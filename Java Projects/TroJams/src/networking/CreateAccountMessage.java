package networking;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import logic.User;

public class CreateAccountMessage extends Message{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private User user;
	private String password;
	private byte[] file;
	
	public CreateAccountMessage(User newUser, String password){
		super("createAccount");
		this.user = newUser;
		this.password = password;
		try {
			File f = new File(newUser.getImageFilePath());
			this.file = Files.readAllBytes(f.toPath());
			
		} catch (IOException e) {
			//TODO we should probably have some better sort of catch block here
			System.out.println("File not found");
			e.printStackTrace();
		}
	}
	
	public String getPassword(){
		return password;
	}
	
	public String getUsername(){
		return user.getUsername();
	}
	
	public String getFirstName(){
		return user.getFirstName();
	}
	
	public String getLastName(){
		return user.getLastName();
	}
	
	public String getEmail(){
		return user.getEmail();
	}
	
	public String getFilepath(){
		return user.getImageFilePath();
	}
	
	public User getUser(){
		return user;
	}
	
	public byte[] getFileAsByteArray(){
		return file;
	}
	
	
	
}

