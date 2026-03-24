shader_type spatial;

uniform float frame_time = 60.0;
uniform sampler2D[2] frames;

void fragment() {
	int curr_frame = int(TIME / frame_time) % 2;
	ALBEDO = texture(frames[curr_frame], UV).rgb;
}

