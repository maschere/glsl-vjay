ArrayList<GShader> shaderList = new ArrayList<GShader>();
int currentShaderIdx = 0;


//load all the suitable shaders from the data directory
//add the parameters for each shader
void setupShaders() {
  //sound input shader
  //GShader soundinput = new GShader("soundinput.glsl");
  //shaderList.add(soundinput);

  //galaxy shader
  GShader galaxy = new GShader("galaxy.glsl");
  shaderList.add(galaxy);
  galaxy.parameters.add(new Param("testbool"));

  //cubescape shader
  GShader cubescape = new GShader("cubescape.glsl");
  shaderList.add(cubescape);
  cubescape.parameters.add(new Param("testbool2"));
  
  
  //init current shader
  initCurrentShader();
}


void initCurrentShader() {
  //remove old osc plugs using new instance
  if (oscP5 != null) {
    oscP5.stop();
    oscP5.dispose();
  }
  oscP5 = new OscP5(this, 12345);

  //osc plug prev / next shaders 
  OscMessage labelData = new OscMessage("/1/label1");
  labelData.add(shaderList.get(currentShaderIdx).path);//append path of current shader to display
  oscP5.send(labelData, remoteAddr);//send the message
  //plug
  oscP5.plug(this,"prevShader","/1/push1");
  oscP5.plug(this,"nextShader","/1/push2");

  //plug prev / next shader
  shaderList.get(currentShaderIdx).addOscPlugs();
}

void prevShader(float val) {
  currentShaderIdx = (currentShaderIdx - 1) % shaderList.size();
  initCurrentShader();
}
void nextShader(float val) {
  currentShaderIdx = (currentShaderIdx + 1) % shaderList.size();
  initCurrentShader();
}