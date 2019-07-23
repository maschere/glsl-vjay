/*{ "osc": 4000 }*/

#ifdef GL_ES
precision mediump float;
#endif


#ifdef GL_ES
precision highp float;
#endif

// Type of shader expected by Processing
#define PROCESSING_COLOR_SHADER

// Processing specific input
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;

uniform float freq1;
uniform float freq2;
uniform float freq3;
uniform float freq4;

uniform float ShiftXUP;
uniform float ShiftX;
uniform float ShiftXLineDistance;
uniform float  ShiftXHorizontal;
uniform float  ShiftXX;
uniform float  ShiftXY;





#define SRC_N 51.0
#define SRC_D 15.5
#define SRC_R 0.503
#define SRC_A .4
#define TWO_PI (2.0 * 3.1415)


void main( void ) {

	vec2 position = gl_FragCoord.xy / resolution.y;
	float max_x = resolution.x / resolution.y;
	vec2 mouse_p = vec2(mouse.x * max_x, ShiftXUP);

	float q = ShiftXY;
	float src_f = TWO_PI * mix(25.0, 50.0, ShiftX);
	float src_d = SRC_D * mix(50.1,  ShiftXX, ShiftXLineDistance);

	for (float i = 0.0; i < SRC_N; i++) {
		vec2 src_pos = vec2((max_x - src_d * (SRC_N - 1.0)) / 2.0 + float(i) * src_d,  ShiftXHorizontal);
		float l = abs(abs(position.x-src_pos.x) - abs(position.y-src_pos.y));
		if (l < SRC_R) {
			gl_FragColor = vec4(1.0);
			return;
		}
		q += sin(l * src_f + i * SRC_A - time * 10.0);
	}
	q /= SRC_N;
	gl_FragColor = vec4(q * q);
}
