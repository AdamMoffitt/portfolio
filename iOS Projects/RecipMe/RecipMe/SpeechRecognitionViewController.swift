//
//  SpeechRecognitionViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/20/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class SpeechRecognitionViewController: UIViewController, SFSpeechRecognizerDelegate {

    
    var unitsOfMeasurement = ["teaspoon", "teaspoons", "tsp", "tbsp", "tablespoon" , "tablespoons", "fluid ounce" , "fluid ounces" , "cup" , "cups" , "pint" , "pints" , "quart" , "quarts" , "gallon" , "gallons" ,"milliliter" , "milliliters" , "liter" , "liters" , "ounce" , "ounces" , "milligram" , "milligrams" , "gram" , "grams" , "kilogram" , "kilograms" , "bag" , "bags" , "can" , "cans" , "box", "boxes" , "pounds", "pound"]
    
    var numbers = ["one" , "1", "two" , "2", "three" , "3", "four" , "4", "five" , "5", "six" , "6", "seven" , "7", "eight" , "8", "nine", "9"]
    
    var speechText : String = ""
    
    private var finalString = ""
    
    @IBOutlet var addItemsTextView: UITextView!
    
    @IBOutlet var speechInputTextView: UITextView!
    
    
    @IBOutlet var startListeningButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addItemsTextView.isEditable = false
        speechInputTextView.isEditable = false
        
        startListeningButton.isEnabled = false

        speechRecognizer.delegate = self

        SFSpeechRecognizer.requestAuthorization { (authStatus) in
  
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            print("c")
            
            OperationQueue.main.addOperation() {
                self.startListeningButton.isEnabled = isButtonEnabled
                print("d")
            }
        }
    }
    
    @IBAction func startListening(_ sender: Any) {
        
    
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startListeningButton.isEnabled = false
            startListeningButton.setTitle("Start Recording", for: .normal)
            self.parseText()
        } else {
            startRecording()
            startListeningButton.setTitle("Stop Recording", for: .normal)        }
    }
    
    func startRecording() {
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.speechText = (result?.bestTranscription.formattedString)!
                self.speechInputTextView.text = self.speechText
                
                isFinal = (result?.isFinal)!
            }
            
            // get ingredients from text
            //var results = parseIngredients(addItemsTextView.text)
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.startListeningButton.isEnabled = true
                self.parseText()
            } 
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    
    /*This function is for parsing the text and finding the food items and quantities in the text. right now, it breaks it into an array of words, and then goes through each word checking to see if it is a number of unit of measurement (as defined in the arrays at the beginning of the file.) if it is a number, it checks the next word to see if it is a unit of measurement. If we find a number followed by a unit of measurement, the next word will be an of and the word after that will be the food item (eg. 5 gallons of milk). Otherwise, if the word after the number is not a unit of measurement, then it is the food item (eg 5 tortillas).
 */
    func parseText () {
        let inputString = self.speechText
        var inputStringArray = inputString.components(separatedBy: " ")
        var index = 0
        
        for i in inputStringArray {
            
            print("\(i) \(index)")
            //print(index)
            //print("a: \(inputStringArray[index])")
            
            //if word is a number
            if(self.numbers.contains(i)){
                //print("!!!!!\(i)")
                print("found number")
                
                //if next word is unit of measurement
                if((inputStringArray.count) > index+1) {
                    if( self.unitsOfMeasurement.contains((inputStringArray[index+1]))){
                        print("*****\(i)")
                        print("found unit of measurement")
                        if((inputStringArray.count) > index+2) {
                            if ( inputStringArray[index+2] == "of"){
                                print("found an of in third spot")
                                if((inputStringArray.count) > index+3) {
                                    self.finalString += "\(inputStringArray[index]) \(inputStringArray[index+1]) of \(inputStringArray[index+3])\n"
                                }
                            }
                        }
                    }
                    else {
                        self.finalString += "\((inputStringArray[index])) \((inputStringArray[index + 1]))"
                    }
                }
                
            }
            
            
            print("fs: \(self.finalString)")
            self.addItemsTextView.text = self.finalString
            index += 1
        }

    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startListeningButton.isEnabled = true
        } else {
            startListeningButton.isEnabled = false
        }
    }

//    parseIngredients(String text) {
//    
//    }
}
