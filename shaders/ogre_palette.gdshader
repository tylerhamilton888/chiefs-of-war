shader_type canvas_item;
// Recolor the red-orange hair/accents in the original full-body artwork.
// The unchanged palette (0) is an exact pass-through.
uniform int palette = 0;
// On paired finisher sheets, an authored rectangle covers only the Ogre's hair/beard.
uniform vec4 hair_region = vec4(0.0);

void fragment() {
    vec4 c = COLOR;
    if (palette > 0 && c.a > 0.0) {
        float red = c.r;
        // Inspect colors in perceptual space; warm skin is otherwise mistaken for red hair.
        vec3 sample_rgb = pow(max(c.rgb, vec3(0.0)), vec3(0.454545));
        float green_ratio = c.g / max(red, 0.001);
        float orange = smoothstep(1.78, 2.20, red / max(c.g, 0.001));
        orange *= smoothstep(0.025, 0.075, green_ratio);
        orange *= 1.0 - smoothstep(0.35, 0.52, c.b / max(c.g, 0.001));
        // Paired sheets contain a second character and blood, so use a more
        // selective color test and an authored player-hair region for those.
        if (hair_region.z > 0.0) {
            green_ratio = sample_rgb.g / max(sample_rgb.r, 0.001);
            orange = smoothstep(2.25, 2.85, sample_rgb.r / max(sample_rgb.g, 0.001));
            orange *= smoothstep(0.025, 0.075, green_ratio);
            orange *= 1.0 - smoothstep(0.65, 0.90, sample_rgb.b / max(sample_rgb.g, 0.001));
        }
        orange *= smoothstep(0.16, 0.27, red);
        float in_hair_region = step(hair_region.x, UV.x) * step(hair_region.y, UV.y)
            * step(UV.x, hair_region.z) * step(UV.y, hair_region.w);
        float deep_red_hair = in_hair_region * smoothstep(2.25, 2.85, sample_rgb.r / max(sample_rgb.g, 0.001)) * smoothstep(0.025, 0.08, red);
        deep_red_hair *= 1.0 - smoothstep(0.35, 0.52, c.b / max(c.g, 0.001));
        orange = max(orange, deep_red_hair);
        vec3 replacement = c.rgb;
        if (palette == 1) replacement = vec3(red * 0.32, red * 0.24, red * 0.19);
        if (palette == 2) replacement = vec3(min(red * 1.05, 1.0), red * 0.65, red * 0.22);
        if (palette == 3) replacement = vec3(red * 0.78, red * 0.76, red * 0.71);
        c.rgb = mix(c.rgb, replacement, orange);
    }
    COLOR = c;
}
