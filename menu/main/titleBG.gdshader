shader_type canvas_item;
uniform float alpha = 1.0;

void fragment() {
	vec4 sprite_color = textureLod(TEXTURE, UV, 0);
	COLOR = vec4(sprite_color.rgb, alpha);
}
