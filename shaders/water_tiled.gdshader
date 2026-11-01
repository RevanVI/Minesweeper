shader_type canvas_item;

uniform float water_color_intensity = 1.0;
uniform float waves_strenght = 1.0;
uniform float waves_speed = 0.1;
uniform float distortion = 0.01;
uniform sampler2D water_texture: filter_nearest, repeat_enable;
uniform sampler2D water_mask: filter_nearest;
uniform sampler2D noise: filter_nearest, repeat_enable;
uniform float noise_size = 512.0;

varying vec2 world_uv;
varying vec2 uv_y;


vec2 get_cell_uv(vec2 uv, vec2 pixel_size) {
	vec2 ut = uv;
	float tile_size = 1.0 / 16.0;
	ut.x = mod(uv.x, pixel_size.x / tile_size) / pixel_size.x * tile_size;
	ut.y = mod(uv.y, pixel_size.y / tile_size) / pixel_size.y * tile_size;
	
	return ut;
}


void vertex() {
	world_uv = (MODEL_MATRIX*vec4(VERTEX, 0.0, 1.0)).xy + 2.0* sin(TIME * 2.0);
}

void fragment() {
	vec2 cell_uv = get_cell_uv(UV, TEXTURE_PIXEL_SIZE);
	
	float mask_value = texture(water_mask, cell_uv).r;
	if (mask_value < 0.9) {
		vec2 world_noise_val = 2.0 * texture(noise, world_uv / noise_size).rg - vec2(1.0);
		vec2 shifted_uv = cell_uv;
		shifted_uv.y += clamp(0.1 * sin(TIME) * world_noise_val.g + 0.03, 0, 1.0);
		mask_value = texture(water_mask, shifted_uv).r;
	}
	
	if (mask_value > 0.9) {
		vec2 noise_val = 2.0 * texture(noise, cell_uv + waves_speed * TIME).rg - vec2(1.0);
		COLOR = texture(water_texture, cell_uv + world_uv / noise_size  + noise_val * waves_strenght) * water_color_intensity;
		
		vec2 tileset_uv = UV + noise_val * distortion;
		if (texture(water_mask, get_cell_uv(tileset_uv, TEXTURE_PIXEL_SIZE)).r < 0.9)
			tileset_uv = UV;
		COLOR *= texture(TEXTURE, tileset_uv);
	}
	//COLOR.rg = get_cell_uv(UV, TEXTURE_PIXEL_SIZE);
}