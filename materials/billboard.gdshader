shader_type spatial;
render_mode unshaded;

uniform float frame_time = 60.0;
uniform sampler2D[9] frames: repeat_enable;

void fragment() {
	int curr_frame = int(TIME / frame_time) % 9;
	ALBEDO = texture(frames[curr_frame], UV).rgb;
	EMISSION = vec3(0.6, 0.6, 0.6);
}
