shader_type canvas_item;

uniform vec4 silhouette_color: source_color = vec4(0.0,0.0,0.0,0.5);
uniform float lod: hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec4 sprite_color = textureLod(TEXTURE, UV, lod);
	COLOR = vec4(silhouette_color.rgb, silhouette_color.a*sprite_color.a);
}