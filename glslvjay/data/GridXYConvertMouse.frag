/*{ "osc": 4000 }*/

#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform float brightness;
uniform float rotation;


uniform float freq1;
uniform float freq2;


//

float gridDE(vec2 p) {

	float size = brightness - 0.005;
	float c1 = mod(p.y-size, abs(freq1-0.5));
	float c2 = mod(p.y+size, abs(freq2-0.5));
	float diff = abs(c1-c2);
	c1 = mod(p.x-size, abs(0.5));
	c2 = mod(p.x+size, abs(0.5));
	diff += abs(c1-c2);
	if (diff > 0.05) diff = 1.0;
	return diff;
}

void main( void ) {

	vec2 pos = ( gl_FragCoord.xy / resolution.xy );
	pos -= vec2(0.5,0.5);

	float d = gridDE(pos);
	gl_FragColor = vec4( d,d,d, 1.0 );

}
