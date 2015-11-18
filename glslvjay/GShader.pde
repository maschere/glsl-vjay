//code partly from https://github.com/genekogan/Processing-Shader-Examples

class GShader
{
  String path;
  PShader myShader;
  ArrayList<Param> parameters;
  

  float masterIntensity = 0.5;
  float masterSpeed = 1.0;
  float i4,i1,i2,i3 = 0.5; //freq band intensities
  int f1Low = 160;
  int f2Low = f1Low*7;
  int f3Low = f2Low*2;
  int f4Low = f3Low*2;
  int f1High = f1Low+50;
  int f2High = f2Low+50;
  int f3High = f3Low+50;
  int f4High = f4Low+50;
  
  //colors and textures
  String color1name,color2name;
  float[] color1,color2;
  String[] tex1files,tex2files;
  int tex1idx,tex2idx = 0;
  PImage tex1,tex2;
  
  
  
  GShader(String path) {
    this.path = path;
    myShader = loadShader(path);
    parameters = new ArrayList<Param>();
    myShader.set("resolution", float(int(vRes*vWidth)), float(int(vRes*vHeight)));  
  }
  

  //sets all the uniforms of this shader. should be called in draw step
  void setUniforms() {
    
    //set frequencies
    scaledMillis += deltaMillis / 1000.0 * masterSpeed * masterSpeed;
    myShader.set("time", scaledMillis);

    float currentFreq = fft.calcAvg(f1Low,f1High);
    if (currentFreq < freqs[0])
      freqs[0] = smoothingDown*freqs[0] + (1-smoothingDown)*currentFreq;
    else
      freqs[0] = smoothingUp*freqs[0] + (1-smoothingUp)*currentFreq;
    myShader.set("freq1",freqs[0]*masterIntensity*i1);

    currentFreq = fft.calcAvg(f2Low,f2High);
    if (currentFreq < freqs[1])
      freqs[1] = smoothingDown*freqs[1] + (1-smoothingDown)*currentFreq;
    else
      freqs[1] = smoothingUp*freqs[1] + (1-smoothingUp)*currentFreq;
    myShader.set("freq2",freqs[1]*masterIntensity*i2);

    currentFreq = fft.calcAvg(f3Low,f3High);
    if (currentFreq < freqs[2])
      freqs[2] = smoothingDown*freqs[2] + (1-smoothingDown)*currentFreq;
    else
      freqs[2] = smoothingUp*freqs[2] + (1-smoothingUp)*currentFreq;
    myShader.set("freq3",freqs[2]*masterIntensity*i3);

    currentFreq = fft.calcAvg(f4Low,f4High);
    if (currentFreq < freqs[3])
      freqs[3] = smoothingDown*freqs[3] + (1-smoothingDown)*currentFreq;
    else
      freqs[3] = smoothingUp*freqs[3] + (1-smoothingUp)*currentFreq;
    myShader.set("freq4",freqs[3]*masterIntensity*i4);
    
    //set colors and textures if not null
    if (color1name!=null && color1!=null)
      myShader.set("myCol1",color1);
    
    if (color2name!=null && color2!=null)
      myShader.set("myCol2",color2);
      
    if (tex1files!=null && tex1!=null)
    {
      myShader.set("iChannel0",tex1); //<>//
      myShader.set("iChannel0ar",tex1.width / float(tex1.height));
    }
      
    if (tex2files!=null && tex2!=null)
    {
      myShader.set("iChannel1",tex2);
    }

    for (Param p : parameters) {
      myShader.set(p.name, p.value);
    }
  }
  
  //adds plugs and sets label for current shader parameters
  void addOscPlugs() {
    
    int toggleNum = 1;
    int sliderNum = 1;
    for (Param p : parameters) {
      if (p.isBool) {
        //bind toggle
        p.plug("/3/toggle"+toggleNum);
        //set label
        setLabel("/3/tlabel"+sliderNum,p.name);
        toggleNum += 1;
      }
      else {
        //bind slider
        p.plug("/3/fader"+sliderNum);
        //set label
        setLabel("/3/label"+sliderNum,p.name);
        sliderNum += 1;
      }
    }
    
    //bind default plugs
    oscP5.plug(this,"intensitySlider","/1/faderIntensity");
    oscP5.plug(this,"speedSlider","/1/faderSpeed");
    oscP5.plug(this,"smoothUpSlider","/1/faderSmoothUp");
    oscP5.plug(this,"smoothDownSlider","/1/faderSmoothDown");
    
    oscP5.plug(this,"setf1Low","/1/freq1low");
    oscP5.plug(this,"setf2Low","/1/freq2low");
    oscP5.plug(this,"setf3Low","/1/freq3low");
    oscP5.plug(this,"setf4Low","/1/freq4low");
    
    oscP5.plug(this,"setf1High","/1/freq1high");
    oscP5.plug(this,"setf2High","/1/freq2high");
    oscP5.plug(this,"setf3High","/1/freq3high");
    oscP5.plug(this,"setf4High","/1/freq4high");
    
    oscP5.plug(this,"setf1Intensity","/1/freq1i");
    oscP5.plug(this,"setf2Intensity","/1/freq2i");
    oscP5.plug(this,"setf3Intensity","/1/freq3i");
    oscP5.plug(this,"setf4Intensity","/1/freq4i");

    oscP5.plug(this,"toggleSlideshow","/2/toggle1");
    
    
    //bind and set labels for color and texture picker
    if (color1name!=null) {
      color1 = new float[4];
      //bind and set color picker 1 
      OscMessage labelData = new OscMessage("/2/colorlabel1");
      labelData.add(color1name);//append these items
      oscP5.send(labelData, remoteAddr);//send the message
      oscP5.plug(this,"setR1","/2/rotary1");
      oscP5.plug(this,"setG1","/2/rotary2");
      oscP5.plug(this,"setB1","/2/rotary3");
      oscP5.plug(this,"setA1","/2/rotary4");
    }
    
    if (color2name!=null) {
      color2 = new float[4];
      //bind and set color picker 2 
      OscMessage labelData = new OscMessage("/2/colorlabel2");
      labelData.add(color2name);//append these items
      oscP5.send(labelData, remoteAddr);//send the message
      oscP5.plug(this,"setR2","/2/rotary5");
      oscP5.plug(this,"setG2","/2/rotary6");
      oscP5.plug(this,"setB2","/2/rotary7");
      oscP5.plug(this,"setA2","/2/rotary8");
    }
    
    if (tex1files!=null){
      setLabel("/2/texlabel1",tex1files[tex1idx]);
      oscP5.plug(this,"prevTex1","/2/prevPush1");
      oscP5.plug(this,"nextTex1","/2/nextPush1");
    }
    
    if (tex2files!=null){
      setLabel("/2/texlabel2",tex2files[tex2idx]);
      oscP5.plug(this,"prevTex2","/2/prevPush2");
      oscP5.plug(this,"nextTex2","/2/nextPush2");
    }
     modTexIdx();
  }
  
  void modTexIdx() {
    //todo: smooth texture blend on change?
    if (tex1files!=null) {

      tex1idx = tex1idx % tex1files.length;
      if (tex1idx < 0)
        tex1idx = tex1files.length-1;
        
      setLabel("/2/texlabel1",tex1files[tex1idx]);
      
      if (tex1files[tex1idx]=="None")
        tex1 = createImage(2, 2, ARGB);
      else if (tex1files[tex1idx].contains("/"))
      {
        File file = new File(dataPath(tex1files[tex1idx]));
        File[] files = file.listFiles();
        tex1 = loadImage(files[int(random(files.length))].getAbsolutePath());
      }
      else
        tex1 = loadImage(tex1files[tex1idx]);
    }
    if (tex2files!=null) {
      tex2idx = tex2idx % tex2files.length;
      if (tex2idx < 0)
        tex2idx = tex2files.length-1;
        
      setLabel("/2/texlabel2",tex2files[tex2idx]);
        
      if (tex2files[tex1idx]=="None")
        tex2 = createImage(2, 2, ARGB);
      else if (tex2files[tex2idx].contains("/"))
      {
        File file = new File(dataPath(tex2files[tex2idx]));
        File[] files = file.listFiles();
        tex2 = loadImage(files[int(random(files.length))].getAbsolutePath());
      }
      else
        tex2 = loadImage(tex2files[tex2idx]);
    }
  }
  
  public void nextTex1(float val) {
    if (val==0.0){
      tex1idx += 1; //<>//
      modTexIdx();
    }
  }
  public void prevTex1(float val) {
    if (val==0.0){
      tex1idx -= 1;
      modTexIdx();
    }
  }
  public void nextTex2(float val) {
    if (val==0.0){
      tex2idx += 1;
      modTexIdx();
    }
  }
  public void prevTex2(float val) {
    if (val==0.0){
      tex2idx -= 1;
      modTexIdx();
    }
  }
  
  public void toggleSlideshow(float val) {
    doSlideshow = val==1.0;
  }
  
  public void setR1(float val) {
    color1[0]=val;
  }
  public void setG1(float val) {
    color1[1]=val;
  }
  public void setB1(float val) {
    color1[2]=val;
  }
  public void setA1(float val) {
    color1[3]=val;
  }
  public void setR2(float val) {
    color2[0]=val;
  }
  public void setG2(float val) {
    color2[1]=val;
  }
  public void setB2(float val) {
    color2[2]=val;
  }
  public void setA2(float val) {
    color2[3]=val;
  }
  
  public void intensitySlider(float val) {
    masterIntensity = val; 
  }
  public void speedSlider(float val) {
    masterSpeed = val;
  }
  public void smoothUpSlider(float val) {
    smoothingUp = sqrt(val);
  }
  public void smoothDownSlider(float val) {
    smoothingDown = sqrt(val);
  }
  
  public void setf1Low(float val) {
    f1Low = 20 + (int)(val*16000);
    f1High = max(f1High, f1Low+5);
  }
  public void setf2Low(float val) {
    f2Low = 20 + (int)(val*16000);
    f2High = max(f2High, f2Low+5);
  }
  public void setf3Low(float val) {
    f3Low = 20 + (int)(val*16000);
    f3High = max(f3High, f3Low+5);
  }
  public void setf4Low(float val) {
    f4Low = 20 + (int)(val*16000);
    f4High = max(f4High, f4Low+5);
  }
  
  public void setf1High(float val) {
    f1High = 20 + (int)(val*16000);
    f1Low = min(f1Low, f1High-5);
  }
  public void setf2High(float val) {
    f2High = 20 + (int)(val*16000);
    f2Low = min(f2Low, f2High-5);
  }
  public void setf3High(float val) {
    f3High = 20 + (int)(val*16000);
    f3Low = min(f3Low, f3High-5);
  }
  public void setf4High(float val) {
    f4High = 20 + (int)(val*16000);
    f4Low = min(f4Low, f4High-5);
  }
  
  public void setf1Intensity(float val) {
    i1 = val;
  }
  public void setf2Intensity(float val) {
    i2 = val;
  }
  public void setf3Intensity(float val) {
    i3 = val;
  }
  public void setf4Intensity(float val) {
    i4 = val;
  }

}