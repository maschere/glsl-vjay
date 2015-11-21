//code partly from https://github.com/genekogan/Processing-Shader-Examples

class GShader
{
  String path;
  String vertexPath;
  PShader myShader;
  ArrayList<Param> parameters;
  ArrayList<AnimParam> animParameters;

  float masterIntensity = 0.5;
  float masterSpeed = 1.0;
  
  float[] freqValue = new float[]{ 0.5,0.5,0.5,0.5 };
  float[] freqIntensity = new float[] { 0.5,0.5,0.5,0.5 };
  int[] freqLow = new int[] { 160, 160*7, 160*7*2, 160*7*2*2 };
  int[] freqHigh = new int[] { 50 + 160, 50 + 160*7, 50 + 160*7*2, 50 + 160*7*2*2 };
  float[] freqSmoothnessUp = new float[] { 0.8,0.8,0.8,0.8 };
  float[] freqSmoothnessDown = new float[] { 0.2,0.2,0.2,0.2 };
  
  int[] beatLowOnset = new int[]{ 0, 9, 18 };
  int[] beatHighOnset = new int[]{ 8, 17, 26 };;
  int[] beatThreshold = new int[]{ 4, 4, 4 };;
  float[] beatValue = new float[3];
  float[] beatSmoothness = new float[3];
  
  //colors and textures
  String color1name,color2name;
  float[] color1,color2;
  String[] tex1files,tex2files;
  int tex1idx,tex2idx = 0;
  PImage tex1,tex2;
  
  
  
  GShader(String path) {
    this(path,null);
  }
   GShader(String path, String vertexPath) {
    this.vertexPath = vertexPath;
    this.path = path;
    myShader = loadShader(path);
    parameters = new ArrayList<Param>();
    animParameters = new ArrayList<AnimParam>();
    myShader.set("resolution", float(int(vRes*vWidth)), float(int(vRes*vHeight)));
  }
  
  
  //for mapping params to computed values, this makes the required lookup
  //i = [0,3] -> 4 freqs
  //i = [4,6] -> 3 beats
  //i = 7 -> time
  float getMappingValue(int i)
  {
    return 0.5;
  }

  //sets all the uniforms of this shader. should be called in draw step
  void setUniforms() {
    
    //set time
    scaledMillis += deltaMillis / 1000.0 * masterSpeed * masterSpeed;
    myShader.set("time", scaledMillis);

    //set frequencies
    for (int i = 0; i < 4; i++)
    {
      float currentFreq = fft.calcAvg(freqLow[i],freqHigh[i]);
      if (currentFreq < freqValue[i])
        freqValue[i] = smoothingDown*freqValue[i] + (1-smoothingDown)*currentFreq;
      else
        freqValue[i] = smoothingUp*freqValue[i] + (1-smoothingUp)*currentFreq;
      myShader.set("freq"+(i+1),freqValue[i]*masterIntensity*freqIntensity[i]);
    }

    
    //set beat
    for (int i = 0; i < 3; i++) {
      if (beat.isRange(beatLowOnset[i], beatHighOnset[i], beatThreshold[i]) )
      {
        beatValue[i] = 1;
      }
      else //decay beat value
      {
        beatValue[i] *= beatSmoothness[i];
      }
      myShader.set("beat"+(i+1), beatValue[i]);
    }
    
    
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

    //static params
    for (Param p : parameters) {
      myShader.set(p.name, p.value);
    }
    
    //animated, mapped params
    for (AnimParam ap : animParameters) {
      if (ap.mappingIdx != -1)
      {
        //set value
        ap.set(getMappingValue(ap.mappingIdx)); 
      }
      myShader.set(ap.name, ap.value);
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
    
    for (int i = 1; i < 5; i++)
    {
      oscP5.plug(this,"setf"+i+"Low","/1/freq"+i+"low");
      oscP5.plug(this,"setf"+i+"High","/1/freq"+i+"high");
      oscP5.plug(this,"setf"+i+"Intensity","/1/freq"+i+"i");
    }

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
    freqLow[0] = 20 + (int)(val*16000);
    freqHigh[0] = max(freqHigh[0], freqLow[0]+5);
  }
  public void setf2Low(float val) {
    freqLow[1] = 20 + (int)(val*16000);
    freqHigh[1] = max(freqHigh[1], freqLow[1]+5);
  }
  public void setf3Low(float val) {
    freqLow[2] = 20 + (int)(val*16000);
    freqHigh[2] = max(freqHigh[2], freqLow[2]+5);
  }
  public void setf4Low(float val) {
    freqLow[3] = 20 + (int)(val*16000);
    freqHigh[3] = max(freqHigh[3], freqLow[3]+5);
  }
  
  public void setf1High(float val) {
    freqHigh[0] = 20 + (int)(val*16000);
    freqLow[0] = min(freqLow[0], freqHigh[0]-5);
  }
  public void setf2High(float val) {
    freqHigh[1] = 20 + (int)(val*16000);
    freqLow[1] = min(freqLow[2], freqHigh[1]-5);
  }
  public void setf3High(float val) {
    freqHigh[2] = 20 + (int)(val*16000);
    freqLow[2] = min(freqLow[2], freqHigh[2]-5);
  }
  public void setf4High(float val) {
    freqHigh[3] = 20 + (int)(val*16000);
    freqLow[3] = min(freqLow[3], freqHigh[3]-5);
  }
  
  public void setf1Intensity(float val) {
    freqIntensity[0] = val;
  }
  public void setf2Intensity(float val) {
    freqIntensity[1] = val;
  }
  public void setf3Intensity(float val) {
    freqIntensity[2] = val;
  }
  public void setf4Intensity(float val) {
    freqIntensity[3] = val;
  }

}