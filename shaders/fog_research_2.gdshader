shader_type canvas_item;

uniform bool enable_pixelation = true;
uniform int pixelation_amount = 150;

uniform vec4 color : source_color;
uniform float strenght = 1.0;
uniform int OCTAVES = 4;
uniform vec2 fog_direction = vec2(1.0, 1.0);

uniform sampler2D fog_sil: filter_nearest;

uniform bool use_mask = false;
uniform sampler2D fog_mask;  
uniform float mask_strenght = 1.0;

varying vec2 world_uv;


float rand(vec2 coord, float seed) {
	coord = mod(coord, 10000.0); //TODO: to avoid artifacts in noise, research later
	float res = fract(sin(dot(coord.xy, vec2(12.9898, 78.233))) *
					(43758.5453123 + seed));
	return res;
}

float noise(vec2 coord, float seed) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	float a = rand(i, seed);
	float b = rand(i + vec2(1.0, 0.0), seed);
	float c = rand(i + vec2(0.0, 1.0), seed);
	float d = rand(i + vec2(1.0, 1.0), seed);

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) +
            (c - a) * cubic.y * (1.0 - cubic.x) +
            (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord, int octaves, float seed) {
	float value = 0.0;
	float scale = 0.65;

	for(int i = 0; i < octaves ; i++) {
		value += noise(coord, seed) * scale;
		coord *= 2.5;
		scale *= 0.5;
	}
	return value;
}

vec2 get_cell_uv(vec2 uv, vec2 pixel_size) {
	vec2 ut = uv;
	float tile_size = 1.0 / 16.0;
	ut.x = mod(uv.x, pixel_size.x / tile_size) / pixel_size.x * tile_size;
	ut.y = mod(uv.y, pixel_size.y / tile_size) / pixel_size.y * tile_size;
	
	return ut;
}


void vertex() {
	world_uv = (MODEL_MATRIX*vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 grid_uv = get_cell_uv(UV, TEXTURE_PIXEL_SIZE);
	
	if (enable_pixelation) {
		grid_uv = floor(grid_uv * float(pixelation_amount)) / float(pixelation_amount);
	}
	vec2 coord = grid_uv * vec2(1.0, 4.0);
        
	vec2 world_uv_id = floor(world_uv / 16.0);
	float motion_seed = rand(world_uv_id, world_uv_id.x + world_uv_id.y);
	vec2 motion = vec2(fbm(coord + fog_direction, OCTAVES, motion_seed));

	float final_seed = rand(world_uv_id, 603.0) * motion_seed * 33.5;
	float final = fbm(coord + motion, OCTAVES, final_seed);
    
	final *= texture(fog_sil, grid_uv).r;
	
	if (use_mask) {
		float mask_value = texture(fog_mask, grid_uv).r;
		final *= mask_value * mask_strenght;
	}
	
	float time_steps = mod(TIME, 4.0 * PI);
	final *= strenght + sin(time_steps * PI * 0.5 + PI / 6.0 * final_seed) * 0.15;

	//quantization
	final = floor(final * 8.0) / 8.0;

	COLOR = vec4(color.rgb * final, COLOR.a);
}