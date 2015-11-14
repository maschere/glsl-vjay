//code partly from https://github.com/genekogan/Processing-Shader-Examples

class GShader
{
  String path;
  PShader myShader;
  ArrayList<Param> parameters;
  

  float masterIntensity = 0.4;
  float masterSpeed = 1.0;
  float i4,i1,i2,i3 = 0.3; //freq band intensities
  int f1 = 160;
  int f2 = f1*7;
  int f3 = f2*2;
  int f4 = f3*2;
  int w1,w2,w3,w4 = 50; //freq band width Hz
  
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
    myShader.set("resolution", float(width), float(height));  
  }
  

  //sets all the uniforms of this shader. should be called in draw step
  void setUniforms() {
    
    //set frequencies
    scaledMillis += deltaMillis / 1000.0 * masterSpeed * masterSpeed;
    myShader.set("time", scaledMillis);

    float currentFreq = fft.calcAvg(max(f1-w1,20),min(f1+w1,16000));
    freqs[0] = smoothing*freqs[0] + (1-smoothing)*currentFreq;
    myShader.set("freq1",freqs[0]*masterIntensity*i1);

    currentFreq = fft.calcAvg(max(f2-w2,20),min(f2+w2,16000));
    freqs[1] = smoothing*freqs[1] + (1-smoothing)*currentFreq;
    myShader.set("freq2",freqs[1]*masterIntensity*i2);

    currentFreq = fft.calcAvg(max(f3-w3,20),min(f3+w3,16000));
    freqs[2] = smoothing*freqs[2] + (1-smoothing)*currentFreq;
    myShader.set("freq3",freqs[2]*masterIntensity*i3);

    currentFreq = fft.calcAvg(max(f4-w4,20),min(f4+w4,16000));
    freqs[3] = smoothing*freqs[3] + (1-smoothing)*currentFreq;
    myShader.set("freq4",freqs[3]*masterIntensity*i4);
    
    //set colors and textures if not null
    if (color1name!=null && color1!=null)
      myShader.set("myCol1",color1);
    
    if (color2name!=null && color2!=null)
      myShader.set("myCol2",color2);
      
    if (tex1files!=null && tex1!=null)
      myShader.set("iChannel0",tex1); //<>//
      
    if (tex2files!=null && tex2!=null)
      myShader.set("iChannel1",tex2);

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
    oscP5.plug(this,"intensitySlider","/1/fader1");
    oscP5.plug(this,"speedSlider","/1/fader3");
    oscP5.plug(this,"smoothSlider","/1/fader2");
    oscP5.plug(this,"padxy1","/1/xy1");
    oscP5.plug(this,"padxy2","/1/xy2");
    oscP5.plug(this,"padxy3","/1/xy3");
    oscP5.plug(this,"padxy4","/1/xy4");
    oscP5.plug(this,"rot1","/1/rotary1");
    oscP5.plug(this,"rot2","/1/rotary2");
    oscP5.plug(this,"rot3","/1/rotary3");
    oscP5.plug(this,"rot4","/1/rotary4");
    
    
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
    //todo: smooth texture blend on change
    if (tex1files!=null) {
      tex1idx = tex1idx % tex1files.length;
      if (tex1idx < 0)
        tex1idx = tex1files.length-1;
        
      setLabel("/2/texlabel1",tex1files[tex1idx]);
      
      if (tex1files[tex1idx]=="None")
        tex1 = createImage(2, 2, ARGB);
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
  public void smoothSlider(float val) {
    smoothing = sqrt(val);
  }
  
  public void padxy1(float y, float x) {
    i1 = y;
    f1 = 20 + (int)(x*16000);
  }
  public void padxy2(float y, float x) {
    i2 = y;
    f2 = 20 + (int)(x*16000);
  }
  public void padxy3(float y, float x) {
    i3 = y;
    f3 = 20 + (int)(x*16000);
  }
  public void padxy4(float y, float x) {
    i4 = y;
    f4 = 20 + (int)(x*16000);
  }
  
  public void rot1(float val) {
    w1 = 1 + (int)(val*8000);
  }
  public void rot2(float val) {
    w2 = 1 + (int)(val*8000);
  }
  public void rot3(float val) {
    w3 = 1 + (int)(val*8000);
  }
  public void rot4(float val) {
    w4 = 1 + (int)(val*8000);
  }

}