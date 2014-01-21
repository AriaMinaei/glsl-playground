attribute vec3 vx;

varying vec2 vTexCoord;

void main() {

	gl_Position = vec4(vx, 1.0);

	vTexCoord = vec2(vx.xy / 2.0 + 0.5);

}