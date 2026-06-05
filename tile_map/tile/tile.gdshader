shader_type canvas_item;

uniform sampler2D palette;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = COLOR.a;
	COLOR = texture(palette, vec2(COLOR.r, 0));
	COLOR.a = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
