shader_type canvas_item;

uniform sampler2D palette;
uniform int precision = 5;

float get_phase_alpha_mult() {
	float mult = 0.0;
	for(int i = 1; i <= precision; i++) {
		mult += floor(mod(TIME / 1.5, 2.0) + 0.3 * float((precision - i)) / float(precision));
	}
	mult = abs(-mult / float(precision) + 1.0);
	return mult;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = COLOR.a;
	if(COLOR.r > 0.9) {
		COLOR = texture(palette, vec2(0.3, 0.75));
	}
	else {
		COLOR = texture(palette, vec2(0.1, 0.75));
	}
	COLOR.a = alpha * get_phase_alpha_mult();
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
