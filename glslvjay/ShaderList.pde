ArrayList<GShader> shaderList = new ArrayList<GShader>();
int currentShaderIdx = 0;


//load all the suitable shaders from the data directory
//add the parameters for each shader
void setupShaders() {
  textureWrap(REPEAT);
  //cubescape shader
  GShader cubescape = new GShader("cubescape.glsl");
  shaderList.add(cubescape);
  cubescape.parameters.add(new Param("brightness",-0.5,5));
  cubescape.parameters.add(new Param("rotation",-1,1));
  cubescape.tex1files = new String[]{ "wood1.jpg" };
  
  //galaxy shader
  GShader galaxy = new GShader("galaxy.glsl");
  shaderList.add(galaxy);
  galaxy.parameters.add(new Param("hideStars"));
  galaxy.tex1files = new String[]{ "seamlesstex/" };

  //ringOfColor shader
  GShader ringOfColor = new GShader("ringofcolor.glsl");
  shaderList.add(ringOfColor);
  //galaxy.parameters.add(new Param("hideStars"));
  //galaxy.tex1files = new String[]{ "seamlesstex/" };
  

  

  
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
  if (val==0.0){
    currentShaderIdx = (currentShaderIdx - 1) % shaderList.size();
    if (currentShaderIdx<0)
      currentShaderIdx=shaderList.size()-1;
    initCurrentShader();
  }
}
void nextShader(float val) {
  if (val==0.0){
    currentShaderIdx = (currentShaderIdx + 1) % shaderList.size();
    initCurrentShader();
  }
}