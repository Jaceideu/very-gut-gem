shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform sampler2D skin_textures[4]: source_color, filter_nearest;
instance uniform int skinId = -1;

void fragment() {
    vec4 albedo_color = texture(albedo_texture, UV);
	if (skinId >= 0) {
		ALBEDO = texture(skin_textures[skinId], UV).rgb;
	}
	else {
		ALBEDO = albedo_color.rgb;
	}
	
    ALPHA = albedo_color.a;
}