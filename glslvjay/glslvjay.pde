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
BeatDetect beat;
BeatListener bl;

//osc
OscP5 oscP5;
NetAddress remoteAddr; //address of your mobile osc device

//scene object to use as backbuffer
PGraphics scene;
float scaledMillis = 0.0;
int deltaMillis = 0;
int oldMillis = 0;

boolean doSlideshow = false;

final int vWidth = 1920;
final int vHeight = 1080;

float vRes = 0.5;

float fftMin=2.0;
float fftMax=20.0;

void settings() {
  //fullScreen(P2D);
  size(int(vRes*vWidth), int(vRes*vHeight), P3D);
}

void setup() {
  frameRate(60);
  scene = createGraphics(int(vRes*vWidth), int(vRes*vHeight), P3D);

  //change this to the ip address of your mobile osc device
  remoteAddr = new NetAddress("192.168.2.104", 12346);
  
  //init minim
  minim = new Minim(this);
  minim.debugOn();

  // get a line in from Minim, default bit depth is 16
  // on windows, set "Stereo Mix" as default input to get the sound that is currently playing
  in = minim.getLineIn(Minim.STEREO, 2048);
  //fft analysis for frequency spectrum
  fft = new FFT(in.bufferSize(), in.sampleRate());
  
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat.detectMode(BeatDetect.FREQ_ENERGY);
  beat.setSensitivity(200);
  bl = new BeatListener(beat, in);  
  
  //load shaders
  setupShaders();
  thread("slideshowThread");
}

void draw() {
  //compute ffts of current frame
  fft.forward(in.mix);

  //set uniforms accordingly for shader
  deltaMillis = millis()-oldMillis;
  oldMillis = millis();
  shaderList.get(currentShaderIdx).setUniforms();

  scene.beginDraw();
  fill(0);
  rect(0, 0, int(vRes*vWidth), int(vRes*vHeight));  
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
  text(int(frameRate), 10, 30);
  
  //show mapping values
  stroke(255,255,255,200);
  strokeWeight(10);
  for (int i = 0; i < 50; i++) {
    float mVal = shaderList.get(currentShaderIdx).getMappingValue(i);
    if (mVal != -1.0)
      line(10+i*15,40,10+i*15,40+int(0.3*vRes*vHeight*mVal));
  }
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
  //get mapping multi toggles here
  String addrP = theOscMessage.addrPattern();
  if (addrP.contains("/4/multitoggle"))
  {
    //get parameter id and toggle id from osc
  }
  else 
  {
    println("### received an osc message.");
    println("### addrpattern\t"+addrP);
    String tt = theOscMessage.typetag();
    println("### typetag\t"+tt);
  }
  }
}


public void slideshowThread() {
  while (true) {
    println("slideshow runnning");
    try
    {    
      Thread.sleep(10000);
      if (doSlideshow==true)
      {
        println("next slide");
        shaderList.get(currentShaderIdx).nextTex1(0.0);
      }
    }
    catch(Exception e){}
  }
}

public void setLabel(String label, String text)
{
  OscMessage labelData = new OscMessage(label);
  labelData.add(text);//append these items
  oscP5.send(labelData, remoteAddr);//send the message 
}

void stop()
{
 // always close Minim audio classes when you are done with them
 in.close();
 minim.stop();

 super.stop();
}

float dB(float x) {
  if (x == 0) {
    return 0;
  }
  else {
    return 10 * (float)Math.log10(x);
  }
}

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source;
  
  BeatListener(BeatDetect beat, AudioInput source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}