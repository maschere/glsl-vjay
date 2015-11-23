# glsl-vjay
Performance-ready Processing sketch to use different GLSL shaders (mostly from shadertoy) for live music visualization with OSC.

glsl-vjay supports / will support the following features:
- [x] easy integration of www.shadertoy.com fragment shaders
- [x] Audio analysis of "What you hear" (requires some setup) using FFT and beat detection
- [x] [TouchOSC](http://hexler.net/software/touchosc) layout to control default parameters (FFT / beat detection settings, speed, shader to use, textures to use) as well as shader specific parameters
- [x] map shader parameters to an OSC control
- [x] Texture-slide show to periodically change input textures for shaders
- [ ] map shader parameters to FFT, BeatDetection or Time
