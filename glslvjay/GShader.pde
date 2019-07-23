//code partly from https://github.com/genekogan/Processing-Shader-Examples

class GShader
{
  String path;
  String vertexPath;
  PShader myShader;
  ArrayList<Param> parameters;
  ArrayList<AnimParam> animParameters;

  float masterIntensity = 0.7;
  float masterSpeed = 1.0;
  
  float[] freqValue = new float[]{ 0.5,0.5,0.5,0.5 };
  int[] freqLow = new int[] { 160, 160*7, 160*7*2, 160*7*2*2 };
  int[] freqHigh = new int[] { 50 + 160, 50 + 160*7, 50 + 160*7*2, 50 + 160*7*2*2 };
  float[] freqSmoothnessUp = new float[] { 0.8,0.8,0.8,0.8 };
  float[] freqSmoothnessDown = new float[] { 0.2,0.2,0.2,0.2 };
  
  int[] beatLowOnset = new int[]{ 0, 9, 18 };
  int[] beatHighOnset = new int[]{ 8, 17, 26 };
  int[] beatThreshold = new int[]{ 4, 4, 4 };
  float[] beatValue = new float[3];
  float[] beatSmoothness = new float[]{ 0.3,0.3,0.3 };
  
  //waveform
  PImage waveImg = createImage(in.bufferSize()/2, 1, RGB);
  float[] wavePixels = new float[in.bufferSize()/2];
  float[] wavePixelsOld = new float[in.bufferSize()/2];
  int waveSmoothnessX = 0;
  float waveSmoothnessY = 0.0;
  
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
    float returnVal = -1.0;
    
    switch (i) {
     case 2:
       returnVal = freqValue[0];
       break;
     case 3:
       returnVal = freqValue[1];
       break;
     case 4:
       returnVal = freqValue[2];
       break;
     case 5:
       returnVal = freqValue[3];
       break;
     case 6:
       returnVal = beatValue[0];
       break;
     case 7:
       returnVal = beatValue[1];
       break;
     case 8:
       returnVal = beatValue[2];
       break;
     case 9:
       returnVal = 0.5*(cos(scaledMillis)+1);
       break;
    }
    
    return returnVal;
  }

  //sets all the uniforms of this shader. should be called in draw step
  void setUniforms() {
    
    //set time
    scaledMillis += deltaMillis / 1000.0 * masterSpeed * masterSpeed;
    myShader.set("time", scaledMillis);

    //set frequencies
    for (int i = 0; i < 4; i++)
    {
      float currentFreqRaw = dB(fft.calcAvg(freqLow[i],freqHigh[i]));
      
      //aweight
      float dbWeight = calculateAWeightingDBAtFrequency(freqLow[i]+(freqHigh[i]-freqLow[i])*0.5);
      
      //cutoff
      currentFreqRaw = max(currentFreqRaw+dbWeight*0.5,fftMin);
      
      if (fftMax < currentFreqRaw)
        fftMax = fftMax*0.4 + currentFreqRaw*0.6;

      float currentFreq = (currentFreqRaw-fftMin)/(fftMax-fftMin);

      if (currentFreq < freqValue[i])
        freqValue[i] = freqSmoothnessDown[i]*freqValue[i] + (1-freqSmoothnessDown[i])*currentFreq;
      else
        freqValue[i] = freqSmoothnessUp[i]*freqValue[i] + (1-freqSmoothnessUp[i])*currentFreq;
      myShader.set("freq"+(i+1),freqValue[i]*masterIntensity);
    }
    //decay min/max
    fftMax = max(0.98*fftMax,1.0);

    
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
      myShader.set("beat"+(i+1), beatValue[i]*masterIntensity);
    }
    
    //set waveform
    
    //get values
    for (int i = 0; i < wavePixels.length; i++) {
      int n = 1;
      float waveVal = in.mix.get(i*2);//(in.mix.get(i*2)+1)/2.0;
      if (i>0)
      {
        waveVal += in.mix.get(i*2 - 1);//(in.mix.get(i*2 - 1)+1)/2.0;
        n += 1;
      }
      if (i<wavePixels.length-1)
      {
        waveVal += in.mix.get(i*2 + 1);//(in.mix.get(i*2 + 1)+1)/2.0;
        n += 1;
      }
      waveVal /= n;
      wavePixels[i] = waveVal; 
    }
    //smoothness
    for (int j = 0; j < waveSmoothnessX; j++) {
       for (int i = 0; i < wavePixels.length; i++) {
        int n = 1;
        float waveVal = wavePixels[i];
        if (i>0)
        {
          waveVal += wavePixels[i-1];
          n += 1;
        }
        if (i<wavePixels.length-1)
        {
          waveVal += wavePixels[i+1];
          n += 1;
        }
        waveVal /= n;
        wavePixels[i] = waveVal; 
      }
    }
    //y smoothness
    waveImg.loadPixels();
    for (int i = 0; i < wavePixels.length; i++) {
      float waveVal = waveSmoothnessY * wavePixelsOld[i] + (1-waveSmoothnessY) * wavePixels[i];
      wavePixelsOld[i] = waveVal;
      waveVal = (waveVal * masterIntensity+1)/2*255;
      waveImg.pixels[i] = color(waveVal,waveVal,waveVal);
    }
    waveImg.updatePixels();
    myShader.set("texWaveform",waveImg);
    
    //set colors and textures if not null
    if (color1name!=null && color1!=null)
      myShader.set("myCol1",color1);
    
    if (color2name!=null && color2!=null)
      myShader.set("myCol2",color2);
      
    if (tex1files!=null && tex1!=null)
    {
      myShader.set("iChannel0",tex1); //<>// //<>//
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
        float mval = getMappingValue(ap.mappingIdx);
        if (mval > -1.0)
        {
          //set value
          ap.set(mval);
        }
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
    
    //bind frequency sliders
    for (int i = 1; i < 5; i++)
    {
      oscP5.plug(this,"setf"+i+"Low","/1/freq"+i+"low");
      oscP5.plug(this,"setf"+i+"High","/1/freq"+i+"high");
      //oscP5.plug(this,"setf"+i+"Intensity","/1/freq"+i+"i");
    }
    
    //bind beat sliders
    for (int i = 1; i < 4; i++)
    {
      oscP5.plug(this,"setb"+i+"Low","/1/beat"+i+"low");
      oscP5.plug(this,"setb"+i+"High","/1/beat"+i+"high");
      //oscP5.plug(this,"setf"+i+"Intensity","/1/freq"+i+"i");
    }
    
    //bind waveform sliders
    oscP5.plug(this,"setwSmoothnessX","/1/waveSmoothX");
    oscP5.plug(this,"setwSmoothnessY","/1/waveSmoothY");

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
      tex1idx += 1; //<>// //<>//
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
  

  //frequency plugs
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
  
  public void setf1smoothUp(float val) {
    freqSmoothnessUp[0] = val;
  }
  public void setf2smoothUp(float val) {
    freqSmoothnessUp[1] = val;
  }
  public void setf3smoothUp(float val) {
    freqSmoothnessUp[2] = val;
  }
  public void setf4smoothUp(float val) {
    freqSmoothnessUp[3] = val;
  }

  public void setf1smoothDown(float val) {
    freqSmoothnessDown[0] = val;
  }
  public void setf2smoothDown(float val) {
    freqSmoothnessDown[1] = val;
  }
  public void setf3smoothDown(float val) {
    freqSmoothnessDown[2] = val;
  }
  public void setf4smoothDown(float val) {
    freqSmoothnessDown[3] = val;
  }


  //beat plugs
  public void setb1smoothDown(float val) {
    beatSmoothness[0] = val;
  }
  public void setb2smoothDown(float val) {
    beatSmoothness[1] = val;
  }
  public void setb3smoothDown(float val) {
    beatSmoothness[2] = val;
  }
  public void setb4smoothDown(float val) {
    beatSmoothness[3] = val;
  }
  
  public void setb1Low(float val) {
    beatLowOnset[0] = (int)(val*beat.detectSize()*0.999);
    beatLowOnset[0] = min(beatLowOnset[0],beatHighOnset[0]);
  }
  public void setb2Low(float val) {
    beatLowOnset[1] = (int)(val*beat.detectSize()*0.999);
    beatLowOnset[1] = min(beatLowOnset[1],beatHighOnset[1]);
  }
  public void setb3Low(float val) {
    beatLowOnset[2] = (int)(val*beat.detectSize()*0.999);
    beatLowOnset[2] = min(beatLowOnset[2],beatHighOnset[2]);
  }
  
  public void setb1High(float val) {
    beatHighOnset[0] = (int)(val*beat.detectSize()*0.999);
    beatHighOnset[0] = max(beatLowOnset[0],beatHighOnset[0]);
  }
  public void setb2High(float val) {
    beatHighOnset[1] = (int)(val*beat.detectSize()*0.999);
    beatHighOnset[1] = max(beatLowOnset[1],beatHighOnset[1]);
  }
  public void setb3High(float val) {
    beatHighOnset[2] = (int)(val*beat.detectSize()*0.999);
    beatHighOnset[2] = max(beatLowOnset[2],beatHighOnset[2]);
  }
  
  public void setb1Threshold(float val) {
    beatThreshold[0] = 1+(int)(val*(beatHighOnset[0]-beatLowOnset[0]));
  }
  public void setb2Threshold(float val) {
    beatThreshold[1] = 1+(int)(val*(beatHighOnset[1]-beatLowOnset[1]));
  }
  public void setb3Threshold(float val) {
    beatThreshold[2] = 1+(int)(val*(beatHighOnset[2]-beatLowOnset[2]));
  }
  
  public void setbSensitivity(float val) {
    beat.setSensitivity(10+int(val*1000)); 
  }
  
  public void setwSmoothnessX(float val) {
    waveSmoothnessX = int(1000*val); 
  }
  public void setwSmoothnessY(float val) {
    waveSmoothnessY = val; 
  }



}
