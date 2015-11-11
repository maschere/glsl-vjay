//use at your own risk. >processing 3.0 required
//requires processing libraries "oscP5" and "minim"

//some code from https://github.com/SableRaf/Processing-Experiments

import netP5.*;
import oscP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

//audio
Minim minim;
AudioInput in;
FFT fft;

//osc
OscP5 oscP5;
NetAddress remoteAddr; //address of your mobile osc device

//scene object to use as backbuffer
PGraphics scene;
float scaledMillis = 0.0;
int deltaMillis = 0;
int oldMillis = 0;

void setup() {
  size(800, 450, P2D);
  frameRate(30);
  scene = createGraphics(width, height, P2D);

  //change this to the ip address of your mobile osc device
  remoteAddr = new NetAddress("192.168.2.104", 12346);
  
  //init minim
  minim = new Minim(this);
  minim.debugOn();

  // get a line in from Minim, default bit depth is 16
  // on windows, set "Stereo Mix" as default input to get the sound that is currently playing
  in = minim.getLineIn(Minim.STEREO, 1024);
  //fft analysis for frequency spectrum
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
 
  //load shaders
  setupShaders();

}

void draw() {
  //compute ffts of current frame
  fft.forward(in.right);

  //set uniforms accordingly for shader
  deltaMillis = millis()-oldMillis;
  oldMillis = millis();
  shaderList.get(currentShaderIdx).setUniforms();

  scene.beginDraw();
  fill(0);
  rect(0, 0, width, height);  
  //apply shader
  shader(shaderList.get(currentShaderIdx).myShader);
  //on a rect
  rect(0, 0, width, height);  
  resetShader();
  scene.endDraw();

  // Display the finished PGraphics
  image(scene, 0, 0, width, height);

  //debug: show fps
  textSize(24);
  fill(255);
  text(((int)frameRate), 10, 30);
}



/*
incoming osc message are forwarded to the oscEvent method.
oscEvent() runs in the background, so whenever a message arrives,
it is input to this method as the "theOscMessage" argument
*/
void oscEvent(OscMessage theOscMessage)
{
  if(theOscMessage.isPlugged()==false) {
  /* print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  String tt = theOscMessage.typetag();
  println("### typetag\t"+tt);
  }
}


void stop()
{
 // always close Minim audio classes when you are done with them
 in.close();
 minim.stop();

 super.stop();
}