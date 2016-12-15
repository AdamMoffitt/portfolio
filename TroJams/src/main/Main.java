package main;

import frames.TrojamWelcomeWindow;
import networking.TrojamClient;

public class Main {

    public static void main (String [] args) {
    	//insert ip address of server and desired port
    	new TrojamWelcomeWindow(new TrojamClient("192.168.111.77", 6789));

    }
}
