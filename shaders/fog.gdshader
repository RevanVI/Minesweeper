shader_type canvas_item;

uniform bool enable_pixelation = true;
uniform int pixelation_amount = 150;

uniform int OCTAVES = 4;
uniform sampler2D tile_mask: filter_nearest;

uniform vec4 base_color: source_color;
uniform sampler2D noise_tex: filter_nearest, repeat_enable;
uniform float noise_tex_size;
uniform vec4 fog_color : source_color;
uniform float strenght = 1.0;

uniform bool use_2 = false;
uniform sampler2D noise_tex_2: filter_nearest, repeat_enable;

uniform bool show_no_color = false;
uniform bool show_only_noise_2 = false;

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
		coord *= 1.5;
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
	vec2 grid_uv = world_uv * vec2(1.0, 1.0);
	//grid_uv.x += sin(TIME * 2.0) * 0.35;
	grid_uv.x += TIME * 2.0;
	
	if (enable_pixelation) {
		grid_uv = floor(grid_uv * float(pixelation_amount)) / float(pixelation_amount);
	}
	float noise_1 = texture(noise_tex, grid_uv / noise_tex_size).r;
	
	float noise_2 = 1.0;
	if (use_2) {
		vec2 moved_grid_uv = grid_uv;// + mod(TIME * 2.0, 512.0);
		moved_grid_uv = floor(moved_grid_uv * 1.0) / 1.0;
		noise_2 = texture(noise_tex_2, moved_grid_uv / 512.0).r;
		noise_2 *= sin(TIME * 0.25) * 0.25 + 0.8;
	}

	float final = noise_1 * noise_2;
	float time_steps = mod(TIME, 4.0);
	final *= strenght + sin(time_steps * PI * 0.5) * 0.45 * fbm(grid_uv, OCTAVES, 12.0);

	//quantization
	final = floor(final * 8.0) / 8.0;
	
	float mask = texture(tile_mask, get_cell_uv(UV, TEXTURE_PIXEL_SIZE)).r;
	COLOR.rgb = mix(base_color.rgb, COLOR.rgb, mask);
	COLOR.rgb = mix(COLOR.rgb, fog_color.rgb * final, final * (1.0 - mask));
	
	if (show_no_color) {
		COLOR.rgb = vec3(final);
	}
	if (show_only_noise_2) {
		COLOR.rgb = vec3(noise_2);
	}
}