//code partly from https://github.com/genekogan/Processing-Shader-Examples

class GShader
{
  String path;
  PShader myShader;
  ArrayList<Param> parameters;
  

  float masterIntensity = 0.5;
  float masterSpeed = 1.0;
  float i4,i1,i2,i3 = 0.3; //freq band intensities
  int f4,f1,f2,f3 = 100; //freq band middle Hz
  int w1,w2,w3,w4 = 10; //freq band width Hz
  
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
    myShader.set("freq1",currentFreq*masterIntensity*i1);

    currentFreq = fft.calcAvg(max(f2-w2,20),min(f2+w2,16000));
    myShader.set("freq2",currentFreq*masterIntensity*i2);

    currentFreq = fft.calcAvg(max(f3-w3,20),min(f3+w3,16000));
    myShader.set("freq3",currentFreq*masterIntensity*i3);

    currentFreq = fft.calcAvg(max(f4-w4,20),min(f4+w4,16000));
    myShader.set("freq4",currentFreq*masterIntensity*i4);
    
    //set colors and textures if not null
    if (color1name!=null)
      myShader.set("myCol1",color1);
    
    if (color2name!=null)
      myShader.set("myCol2",color2);
      
    if (tex1files!=null)
      myShader.set("myTex1",tex1);
      
    if (tex2files!=null)
      myShader.set("myTex2",tex2);

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
        OscMessage labelData = new OscMessage("/3/tlabel"+sliderNum);
        labelData.add(p.name);//append these items
        oscP5.send(labelData, remoteAddr);//send the message
        toggleNum += 1;
      }
      else {
        //bind slider
        p.plug("/3/fader"+sliderNum);
        //set label
        OscMessage labelData = new OscMessage("/3/label"+sliderNum);
        labelData.add(p.name);//append these items
        oscP5.send(labelData, remoteAddr);//send the message
        sliderNum += 1;
      }
    }
    
    //bind default plugs
    oscP5.plug(this,"intensitySlider","/1/fader1");
    oscP5.plug(this,"speedSlider","/1/fader2");
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
      OscMessage labelData = new OscMessage("/2/texlabel1");
      labelData.add(tex1files[tex1idx]);//append these items
      oscP5.send(labelData, remoteAddr);//send the message
      oscP5.plug(this,"prevTex1","/2/push1");
      oscP5.plug(this,"nextTex1","/2/push2");
    }
    
    if (tex2files!=null){
      OscMessage labelData = new OscMessage("/2/texlabel2");
      labelData.add(tex2files[tex2idx]);//append these items
      oscP5.send(labelData, remoteAddr);//send the message
      oscP5.plug(this,"prevTex2","/2/push3");
      oscP5.plug(this,"nextTex2","/2/push4");
    }
  }
  
  void modTexIdx() {
    //todo: smooth texture blend on change
    if (tex1files!=null) {
      tex1idx = tex1idx % tex1files.length;
      tex1 = loadImage(tex1files[tex1idx]);
    }
    if (tex2files!=null) {
      tex2idx = tex2idx % tex2files.length;
      tex2 = loadImage(tex2files[tex2idx]);
    }
  }
  
  public void nextTex1(float val) {
    tex1idx += 1;
    modTexIdx();
  }
  public void prevTex1(float val) {
    tex1idx -= 1;
    modTexIdx();
  }
  public void nextTex2(float val) {
    tex2idx += 1;
    modTexIdx();
  }
  public void prevTex2(float val) {
    tex2idx -= 1;
    modTexIdx();
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