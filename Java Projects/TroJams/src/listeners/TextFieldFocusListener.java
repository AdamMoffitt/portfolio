package listeners;

import java.awt.Color;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;

import javax.swing.JTextField;
//sets default text in the textfield, and removes it when you start typing
public class TextFieldFocusListener implements FocusListener{

	private String defaultText;
	private JTextField thisTextField;
	
	public TextFieldFocusListener(String defaultText, JTextField thisTextField) {
		this.defaultText = defaultText;
		this.thisTextField = thisTextField;
		//set the text to default initially
		thisTextField.setText(defaultText);
		thisTextField.setForeground(Color.gray);
	}

	@Override
    public void focusGained(FocusEvent fe)
    {
		thisTextField.setForeground(Color.black);
        thisTextField.setText("");
	    
    }

    @Override
    public void focusLost(FocusEvent fe)
    {
    	if (thisTextField.getText().equals("")){
    		thisTextField.setForeground(Color.gray);
	    	thisTextField.setText(defaultText);
    	}
    
    }
}
