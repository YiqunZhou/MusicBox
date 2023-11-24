//This code was built from the "Knight Rider" example code

//import library
import processing.video.*;
import processing.sound.*;
import cc.arduino.*;
import processing.serial.*;
import java.lang.System;

// Declare variables

Capture cam;

//SoundFile sound; 



int buzzerPin=9;

color targetColor = color(0, 0, 0); // Target color to detect (red in this case)

int startX = 0;
int startY = 0;
int areaWidth = 640;
int areaHeight = 100;

int detectionThreshold = 20; // Color detection threshold

boolean sound = false;
long t = 0;
Serial port;
// initialize an array to call notes from Arduino
int[] Melody = {0, 1,2, 3, 4, 5, 6, 7};

void setup() {
  size(640, 480);
  


  // Initialize the webcam
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras found");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    // Use the first available camera
    cam = new Capture(this, 640, 480, cameras[2]);
    cam.start();
  }
  // Serial Port Setup
  String portName = Serial.list()[5];  // Adjust index based on your setup
  port = new Serial(this, portName, 9600);
  
}

void draw() {
  background(255);
  
  // Check if the webcam is capturing
  if (cam.available()){
    cam.read();
  }
  
  
  // Display the webcam feed
  image(cam, 0, 0, width, height);
  
  // reading area
  noFill();
  stroke(0, 0, 0); // Green color for the rectangle
  strokeWeight(1);
  rect(width/2-25, 0, 50, height);
  
  // not reading area
  fill(50,210);
  rect(0, 0, width/2-25, height);
  rect(width/2+25, 0, width/2-25, height);
  
  // Detect the target color within a defined area
  detectColor();
}

void detectColor() {
  
  // Define the area to check for the target color (example: top strip)
  
  int startX = width/2-25;
  int startY = 0;
  int areaWidth = 50;
  int areaHeight = height/8; 
  int count = 0;
 
  
  //Looop through 8 areas
  for(int areCount =0 ; areCount<8 ;areCount++ )  
  {
  
  // Loop through the pixels in the defined area
  for (int y = startY + areaHeight* areCount; y < (startY + areaHeight* areCount) + areaHeight; y++) {
    for (int x = startX; x < startX + areaWidth; x++) {
      // Get the color of the current pixel
      //This color detection function was written by ChatGPT 3 on November 18th, 2023
      color currentColor = cam.get(x, y);
      
  // Calculate the difference between the target color and the current pixel color
      float d = dist(red(targetColor), green(targetColor), blue(targetColor), 
                     red(currentColor), green(currentColor), blue(currentColor));


            
  // Check if the difference is within the detection threshold
      long t2 = System.currentTimeMillis();
      if (d < detectionThreshold ) {
            // check for 20 black pixels
            count ++;
            if (count > 20){
        println ("detected");
        // Highlight the detected area by drawing a rectangle around it
        noFill();
        stroke(0, 255, 0); // Green color for the rectangle
        strokeWeight(2);
        rect(startX, startY + areaHeight* areCount, areaWidth, areaHeight);
        // going through melody array and checking for areas.
       for (int areaNum = 0 ; areaNum<8; areaNum++){
        if(!sound && areaHeight*areaNum < y && y <areaHeight *(areaNum+1)) {
             // using serial port calling Arduino to play notes from pitch.h library
          port.write(Melody[areaNum] + "\n");
   
          sound = true;
          t = System.currentTimeMillis();     
        }
       }
        break;
      }
      
      else if(sound && t2 - t > 300) { //half a second, t past time, t2 is current time 
      println("not detected");
      port.write(0 + "\n");
      //arduino.digitalWrite(buzzerPin, Arduino.LOW);
      sound = false;
      return;
      }
        
      } 
      }
    }
  }
  }

        
   
