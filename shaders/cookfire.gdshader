shader_type canvas_item;
// UVs identify the space between the painted legs and the fire-facing iron.
// The rim, heraldry and outlines use their original samples at every frame.
uniform float fire_clock = 0.0;
uniform float ember = 0.6;
varying vec4 tint;

void vertex() {
    tint = COLOR;
}

float flame(vec2 uv, vec2 root, float width, float height, float seed) {
    float t = fire_clock * 5.0 + seed;
    float rise = (root.y - uv.y) / (height * (0.85 + 0.15 * sin(t)));
    float lean = (sin(t * 1.21 + rise * 2.0) + 0.45 * sin(t * 1.79 - rise * 4.0)) * 0.011 * rise;
    float radius = width * (1.0 - smoothstep(0.08, 1.0, rise));
    float edge = 1.0 - smoothstep(radius, radius + 0.005, abs(uv.x - root.x - lean));
    return edge * smoothstep(-0.04, 0.12, rise) * (1.0 - smoothstep(0.84, 1.0, rise));
}

void fragment() {
    vec4 paint = texture(TEXTURE, UV);
    float warm_pigment = smoothstep(0.08, 0.42, paint.r - paint.b);
    float under_kettle = 1.0 - smoothstep(0.72, 1.0, length((UV - vec2(0.50, 0.795)) / vec2(0.247, 0.115)));
    paint.rgb *= 1.0 + (ember - 0.60) * 0.84 * warm_pigment * under_kettle;
    float fire = max(flame(UV, vec2(0.499, 0.843), 0.027, 0.106, 0.0),
                     flame(UV, vec2(0.405, 0.793), 0.021, 0.063, 1.8));
    fire = max(fire, flame(UV, vec2(0.577, 0.800), 0.019, 0.064, 4.3));
    vec3 gold = mix(vec3(1.0, 0.42, 0.10), vec3(1.0, 0.84, 0.28), smoothstep(0.736, 0.849, UV.y));
    paint.rgb = mix(paint.rgb, gold, fire * 0.81);
    float reflected = 1.0 - smoothstep(0.15, 1.0, length((UV - vec2(0.49, 0.725)) / vec2(0.39, 0.16)));
    paint.rgb += vec3(0.16, 0.063, 0.010) * reflected * (0.25 + 0.75 * ember);
    COLOR = paint * tint;
}
