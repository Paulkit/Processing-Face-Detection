import processing.video.*;
import gab.opencv.*;
import java.awt.*;

/**
 Name: Chu Chung Kit
 SID: 53561007
 CS3483 Multimodal Interface Design Assignment
 Date: 6-11-2016
 */

Capture cam;
PImage img;
PImage humanImg;
OpenCV opencv;
OpenCV opencvBlurImg;
OpenCV opencvhuman;


int stateCheck = 1; // 1 - Initial Setup,  3 - Viewing the image, 4. Modifying the image, 5. Replacing the faces
final int unactiveColor = 0xFFA6A49F; // unactive color for text display
final int activeColor = 0xFF007EAE; // active color for text display
final int displayWidth = 1024; // window's width
final int displayHeight = 500; // window's height
final int camX = 704; // camera window's width
final int camY = 260; // camera window's height

int ScreenMoveDetect = 0;

/** Dectect key input and keep perform correspond function */
void keyPressed() { 

  if (key == 'v') { // Viewing the image
    stateCheck = 3;
  } else if (key == 'm' ) { // Modifying the image
    image(img, 0, 0);
    stateCheck = 4;
  } else if (key == 'f') { // Face detection
    stateCheck = 5;
  } else if (key == 'e') { // exit 
    stateCheck = 1;
  }
}

void Initial() {

  if (cam.available() == true) {
    cam.read();
  }

  image(img, 0, 0);

  if (cam.available()==true) cam.read();    
  opencv.loadImage(cam);          
  Rectangle[] faces = opencv.detect();   
  image(cam, camX, camY/*, 224, 224*/);   

  noFill();    
  stroke(0, 255, 0);    
  if (faces.length>0) {  
    for ( int i=0; i<faces.length; i++) {   

      rect(faces[i].x + camX, faces[i].y + camY, faces[i].width, faces[i].height);
    }
  }
}

void Viewing() {


  opencvBlurImg = new OpenCV(this, img );      
  opencvBlurImg.useColor();

  if (cam.available() == true) {
    cam.read();
  } 
  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();
  image(cam, camX, camY);   
  noFill();    
  stroke(0, 255, 0);    

  if (faces.length>0) {  
    for ( int i=0; i<faces.length; i++) {

      opencvBlurImg.setROI(0, 0, faces[i].x, img.height); 
      opencvBlurImg.blur(10);  
      opencvBlurImg.setROI(faces[i].x, 0, img.width - faces[i].x, faces[i].y); 
      opencvBlurImg.blur(10); 
      opencvBlurImg.setROI(faces[i].x + faces[i].width, faces[i].y, img.width - (faces[i].x + faces[i].width ), img.height - faces[i].y); 
      opencvBlurImg.blur(10); 

      opencvBlurImg.setROI(faces[i].x, faces[i].y + faces[i].height, img.width - faces[i].x, img.height - (faces[i].y+ faces[i].height)); 
      opencvBlurImg.blur(10); 

      rect(faces[i].x + camX, faces[i].y + camY, faces[i].width, faces[i].height);

      image(opencvBlurImg.getOutput(), 0, 0 );
    }
  } else {

    image(opencvBlurImg.getOutput(), 0, 0 );
  }
  opencvBlurImg.releaseROI();
}

void Modifying() {

  if (cam.available() == true) {
    cam.read();
  }



  if (cam.available()==true) cam.read();    
  opencv.loadImage(cam);
  Rectangle[] faces = opencv.detect();   
  image(cam, camX, camY/*, 224, 224*/);   

  noFill();
  stroke(0, 255, 0);
  if (faces.length>0) {
    for ( int i=0; i<faces.length; i++) {  
      rect(faces[i].x + camX, faces[i].y + camY, faces[i].width, faces[i].height);
      if (ScreenMoveDetect!=faces[i].x) { // do draw circle
       ScreenMoveDetect = faces[i].x;
       color c = get(faces[i].x, faces[i].y);
       fill(c);
       stroke(c);
       
        int size = (int)random(10, 30);
        ellipse((int)random(faces[i].x, faces[i].x + faces[i].width), (int)random(faces[i].y, faces[i].y + faces[i].height), size, size);
      }
    }
  }
}

void Replacing() {


  humanImg = loadImage("human.jpg");

  if (cam.available() == true) {
    cam.read();
  }

  image(humanImg, 0, 0);

  if (cam.available()==true) cam.read();    
  opencv.loadImage(cam);          

  opencvhuman.loadImage(humanImg);     

  Rectangle[] faces = opencv.detect();  
  Rectangle[] opencvhumanFaces = opencvhuman.detect();     
  image(cam, camX, camY/*, 224, 224*/);   

  noFill();    
  int opencvhumanFacesX = 0;
  int opencvhumanFacesY= 0;
  int opencvhumanFacesWidth= 0;
  int opencvhumanFacesHeight= 0;
  stroke(255, 0, 0); 
  if (opencvhumanFaces.length>0) {  
    for ( int i=0; i<opencvhumanFaces.length; i++) { 
      opencvhumanFacesX = opencvhumanFaces[i].x;
      opencvhumanFacesY = opencvhumanFaces[i].y;
      opencvhumanFacesWidth = opencvhumanFaces[i].width;
      opencvhumanFacesHeight = opencvhumanFaces[i].height;
      rect(opencvhumanFaces[i].x, opencvhumanFaces[i].y, opencvhumanFaces[i].width, opencvhumanFaces[i].height);
    }
  }

  stroke(0, 255, 0); 
  if (faces.length>0) {  
    for ( int i=0; i<faces.length; i++) {   
      rect(faces[i].x + camX, faces[i].y + camY, faces[i].width, faces[i].height);


      PVector  v1 = new PVector(opencvhumanFacesX, opencvhumanFacesY, 0);
      PVector  v2 = new PVector(faces[i].x, faces[i].y, 0); 
      int d = (int)v1.dist(v2); // Calculates the Euclidean distance between two points

      if ( d<=8 && d>=-8) { //  position indicator is close to a face
        // get camera face
        PImage c = get(faces[i].x + camX, faces[i].y + camY, faces[i].width, faces[i].height);
         // replace camera face to the image face
        image(c, opencvhumanFacesX, opencvhumanFacesY, opencvhumanFacesWidth, opencvhumanFacesHeight);
      } else {
        // show rectamgle to let user know how close his/her face to the image face
        rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
      }
    }
  }
}

/** Starting point of program */
void setup() {
  size(displayWidth, displayHeight);
  background(0xAAE3EFF2);
  img = loadImage("pexels-photo-medium.jpg");

  cam = new Capture(this, 320, 240); 
  cam.start();
  
  opencv = new OpenCV(this, 320, 240);        
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  opencvhuman = new OpenCV(this, 320, 240);       
  opencvhuman.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  textSize(36);
}

/** Display text to let user know which mode he/she currently use*/
void displayText() {

  if (stateCheck == 3 ) {
    fill(activeColor);
  } else { 
    fill(unactiveColor);
  }  
  text("View image mode    - (Press v)", 30, 370); 
  if (stateCheck == 4 ) {
    fill(activeColor);
  } else { 
    fill(unactiveColor);
  }  
  text("Modify image mode - (Press m)", 30, 420);
  if (stateCheck == 5 ) {
    fill(activeColor);
  } else { 
    fill(unactiveColor);
  }  
  text("Replace face mode   - (Press f)", 30, 470);
}

/** looping content */
void draw() {
  displayText(); // keep updating text
  switch(stateCheck) {
  case 1:
    Initial();
    break;
  case 3:
    Viewing();
    break;
  case 4:
    Modifying();
    break;
  case 5:
    Replacing();
    break;
  }
}