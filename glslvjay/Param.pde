//code mostly from https://github.com/genekogan/Processing-Shader-Examples

class Param 
{
  String name;
  float value;
  float minValue, maxValue;
  boolean isBool = false;
  
  Param(String name, float minValue, float maxValue) {
    this.name = name;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.set(0.5);
  }
  
  Param(String name) {
    this.name = name;
    this.set(0.0);
    isBool = true;    
  }

  public void set(float valuenorm) {
    if (isBool==false)
      this.value = minValue + valuenorm * (maxValue-minValue);
    else
      this.value = (valuenorm==1.0?1.0:0.0);
  }
  
  void plug(String pattern){
    oscP5.plug(this,"set",pattern);
  }

}

class AnimParam extends Param
{
  int mappingIdx = -1;
  
  final float trueMin;
  final float trueMax;
  
  AnimParam(String name, float minValue, float maxValue) {
     super(name,minValue,maxValue);
     trueMin = minValue;
     trueMax = maxValue;
  }
  
  public void setCutOffMin(float val) {
    minValue = trueMin + val * (trueMax-trueMin);
    if (minValue > maxValue)
      minValue = maxValue;
  }
  public void setCutOffMax(float val) {
    maxValue = trueMax - val * (trueMax-trueMin);
    if (maxValue < minValue)
      maxValue = minValue;
  }
}