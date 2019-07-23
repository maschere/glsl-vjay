//code from http://stackoverflow.com/questions/20408388/how-to-filter-fft-data-for-audio-visualisation

final float[] aWeightFrequency = { 
  10, 12.5, 16, 20, 
  25, 31.5, 40, 50, 
  63, 80, 100, 125, 
  160, 200, 250, 315, 
  400, 500, 630, 800, 
  1000, 1250, 1600, 2000, 
  2500, 3150, 4000, 5000,
  6300, 8000, 10000, 12500, 
  16000, 20000 
};

final float[] aWeightDecibels = {
  -70.4, -63.4, -56.7, -50.5, 
  -44.7, -39.4, -34.6, -30.2, 
  -26.2, -22.5, -19.1, -16.1, 
  -13.4, -10.9, -8.6, -6.6, 
  -4.8, -3.2, -1.9, -0.8, 
  0.0, 0.6, 1.0, 1.2, 
  1.3, 1.2, 1.0, 0.5, 
  -0.1, -1.1, -2.5, -4.3, 
  -6.6, -9.3 
};

float calculateAWeightingDBAtFrequency(float frequency) {
  return linterp(aWeightFrequency, aWeightDecibels, frequency);    
}

float linterp(float[] x, float[] y, float xx) {
  assert(x.length > 1);
  assert(x.length == y.length);

  float result = 0.0;
  boolean found = false;

  if (x[0] > xx) {
    result = y[0];
    found = true;
  }

  if (!found) {
    for (int i = 1; i < x.length; i++) {
      if (x[i] > xx) {
        result = y[i-1] + ((xx - x[i-1]) / (x[i] - x[i-1])) * (y[i] - y[i-1]);
        found = true;
        break;
      }
    }
  }

  if (!found) {
    result = y[y.length-1];
  }

  return result;     
}
