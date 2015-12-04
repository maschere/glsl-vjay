# glsl-vjay
Performance-ready [Processing](https://processing.org/) sketch to use different GLSL shaders (mostly from shadertoy) for live music visualization with OSC.

glsl-vjay supports / will support the following features:
- [x] easy integration of www.shadertoy.com fragment shaders
- [x] Audio analysis
  - [x] live input from "Stereomix" / "What you hear" (requires some setup)
  - [x] FFT, waveform and beat detection
- [x] [TouchOSC](http://hexler.net/software/touchosc) layout for live adjustments
  - [x] sensitivity and smoothness 
  - [x] speed and intensity
  - [x] shader / texture selection
  - [x] shader specific parameters
- [x] automatically maps shader parameters to an OSC control
- [x] Texture slide-show
  - [x] periodically change input textures for shaders
  - [ ] smooth blending between two textures
- [ ] map shader parameters to dynamic values from FFT, BeatDetection or Time
- [ ] support for multipass / feedback shaders
