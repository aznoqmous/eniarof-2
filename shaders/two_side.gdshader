shader_type spatial;

uniform sampler2D side_texture;
uniform sampler2D top_texture;

uniform vec2 tilling_side = vec2(1.0);
uniform vec2 offset_side = vec2(0.0);

uniform vec2 tilling_top = vec2(1.0);
uniform vec2 offset_top = vec2(0.0);

void vertex() {
	// Called for every vertex the material is visible on.

}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	float dot = dot(worldNormal,vec3(0.0,1.0,0.0));
	
	vec4 color = vec4(0.);
	
	if(abs(dot) <=0.9){
		color = texture(side_texture,(UV+offset_side)*tilling_side);
	}
	else{
		color = texture(top_texture,UV*tilling_top+offset_top);
	}
	ALBEDO = color.xyz;
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
