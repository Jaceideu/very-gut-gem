shader_type spatial;

instance uniform int rand_index = 0;
uniform sampler2D[8] textures;


void fragment() {
	ALBEDO = texture(textures[rand_index], UV).rgb;	
}
