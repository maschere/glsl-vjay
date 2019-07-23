ArrayList<GShader> shaderList = new ArrayList<GShader>();
int currentShaderIdx = 0;


//load all the suitable shaders from the data directory
//add the parameters for each shader
void setupShaders() {
  textureWrap(REPEAT);
  
  //soundinput shader ZERO-INIT
  GShader inputsound = new GShader("inputsound.frag");
  shaderList.add(inputsound);
  
  //cubescape shader
  GShader cubescape = new GShader("cubescape.frag");
  shaderList.add(cubescape);
  cubescape.parameters.add(new Param("brightness",-0.5,5));
  cubescape.parameters.add(new Param("rotation",-1,1));
  cubescape.tex1files = new String[]{ "wood1.jpg" };
  
  //galaxy shader
  GShader galaxy = new GShader("galaxy.frag");
  shaderList.add(galaxy);
  galaxy.parameters.add(new Param("hideStars"));
  galaxy.tex1files = new String[]{ "seamlesstex/" };

  //ringOfColor shader
  GShader ringOfColor = new GShader("ringofcolor.glsl");
  shaderList.add(ringOfColor);
  galaxy.parameters.add(new Param("hideStars"));
  galaxy.tex1files = new String[]{ "seamlesstex/" };
  
// x.glsl FIRST
  GShader x = new GShader("x.frag");
  shaderList.add(x);
  x.parameters.add(new Param("ShiftXUP",-0.5,5));
  x.parameters.add(new Param("ShiftX",-0.5,5));
  x.parameters.add(new Param("ShiftXLineDistance",-0.5,5));
  x.parameters.add(new Param("ShiftXHorizontal",-0.5,5));
  x.parameters.add(new Param("ShiftXX",-0.5,5));
  x.parameters.add(new Param("ShiftXY",-0.5,5));
  
   
 //GridXYConvertMouse.frag
  GShader GridXYConvertMouse = new GShader("GridXYConvertMouse.frag");
  shaderList.add(GridXYConvertMouse);
 
  //linemorph.frag
GShader linemorph = new GShader("linemorph.frag");
  shaderList.add(linemorph);
  
  //init current shader
  initCurrentShader();
}


void initCurrentShader() {
  //remove old osc plugs using new instance
  if (oscP5 != null) {
    oscP5.stop();
    oscP5.dispose();
  }
  oscP5 = new OscP5(this, 4000);

  //osc plug prev / next shaders 
  OscMessage labelData = new OscMessage("/1/label1");
  labelData.add(shaderList.get(currentShaderIdx).path);//append path of current shader to display
  oscP5.send(labelData, remoteAddr);//send the message
  //plug
  oscP5.plug(this,"prevShader","/1/push1");
  oscP5.plug(this,"nextShader","/1/push2");
  
  oscP5.plug(this,"pick1","//1/label1/multitoggle1/2/1");
  oscP5.plug(this,"pick2","//1/label1/multitoggle1/2/2");
  oscP5.plug(this,"pick3","//1/label1/multitoggle1/2/3");
  oscP5.plug(this,"pick4","//1/label1/multitoggle1/2/4");
  oscP5.plug(this,"pick5","//1/label1/multitoggle1/2/5");
  oscP5.plug(this,"pick6","//1/label1/multitoggle1/2/6");
  oscP5.plug(this,"pick7","//1/label1/multitoggle1/2/7");
  oscP5.plug(this,"pick8","//1/label1/multitoggle1/2/8");
  oscP5.plug(this,"pick9","//1/label1/multitoggle1/2/9");
  oscP5.plug(this,"pick10","//1/label1/multitoggle1/2/10");
  
  oscP5.plug(this,"pick11","//1/label1/multitoggle1/1/1");
  oscP5.plug(this,"pick12","//1/label1/multitoggle1/1/2");
  oscP5.plug(this,"pick13","//1/label1/multitoggle1/1/3");
  oscP5.plug(this,"pick14","//1/label1/multitoggle1/1/4");
  oscP5.plug(this,"pick15","//1/label1/multitoggle1/1/5");
  oscP5.plug(this,"pick16","//1/label1/multitoggle1/1/6");
  oscP5.plug(this,"pick17","//1/label1/multitoggle1/1/7");
  oscP5.plug(this,"pick18","//1/label1/multitoggle1/1/8");
  oscP5.plug(this,"pick19","//1/label1/multitoggle1/1/9");
  oscP5.plug(this,"pick20","//1/label1/multitoggle1/1/10");

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


void pick1(float val) {
  if (val==0.0){
    currentShaderIdx = 1;
    initCurrentShader();
  }
}
void pick2(float val) {
  if (val==0.0){
    currentShaderIdx = 2;
    initCurrentShader();
  }
}
//void pick3(float val) {
//  if (val==0.0){
//    currentShaderIdx = 3;
//    initCurrentShader();
//  }
//}
//void pick4(float val) {
//  if (val==0.0){
//    currentShaderIdx = 4;
//    initCurrentShader();
//  }
//}
//void pick5(float val) {
//  if (val==0.0){
//    currentShaderIdx = 5;
//    initCurrentShader();
//  }
//}
//void pick6(float val) {
//  if (val==0.0){
//    currentShaderIdx = 6;
//    initCurrentShader();
//  }
//}
//void pick7(float val) {
//  if (val==0.0){
//    currentShaderIdx = 7;
//    initCurrentShader();
//  }
//}
//void pick8(float val) {
//  if (val==0.0){
//    currentShaderIdx = 8;
//    initCurrentShader();
//  }
//}
//void pick9(float val) {
//  if (val==0.0){
//    currentShaderIdx = 9;
//    initCurrentShader();
//  }
//}
//void pick10(float val) {
//  if (val==0.0){
//    currentShaderIdx = 10;
//    initCurrentShader();
//  }
//}
//void pick11(float val) {
//  if (val==0.0){
//    currentShaderIdx = 11;
//    initCurrentShader();
//  }
//}
//void pick12(float val) {
//  if (val==0.0){
//    currentShaderIdx = 12;
//    initCurrentShader();
//  }
//}
//void pick13(float val) {
//  if (val==0.0){
//    currentShaderIdx = 13;
//    initCurrentShader();
//  }
//}
//void pick14(float val) {
//  if (val==0.0){
//    currentShaderIdx = 14;
//    initCurrentShader();
//  }
//}
//void pick15(float val) {
//  if (val==0.0){
//    currentShaderIdx = 15;
//    initCurrentShader();
//  }
//}
//void pick16(float val) {
//  if (val==0.0){
//    currentShaderIdx = 16;
//    initCurrentShader();
//  }
//}
//void pick17(float val) {
//  if (val==0.0){
//    currentShaderIdx = 17;
//    initCurrentShader();
//  }
//}
//void pick18(float val) {
//  if (val==0.0){
//    currentShaderIdx = 18;
//    initCurrentShader();
//  }
//}
//void pick19(float val) {
//  if (val==0.0){
//    currentShaderIdx = 19;
//    initCurrentShader();
//  }
//}
//void pick20(float val) {
//  if (val==0.0){
//    currentShaderIdx = 20;
//   initCurrentShader();
//  }
//}
