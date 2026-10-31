shader_type canvas_item;
// Recolor the red-orange hair/accents in the original full-body artwork.
// The unchanged palette (0) is an exact pass-through.
uniform int palette = 0;
void fragment() {
    vec4 c = COLOR;
    if (palette > 0 && c.a > 0.0) {
        float red = c.r;
        float green_ratio = c.g / max(red, 0.001);
        float orange = smoothstep(1.78, 2.20, red / max(c.g, 0.001));
        orange *= smoothstep(0.075, 0.16, green_ratio);
        orange *= 1.0 - smoothstep(0.65, 0.90, c.b / max(c.g, 0.001));
        orange *= smoothstep(0.16, 0.27, red);
        vec3 replacement = c.rgb;
        if (palette == 1) replacement = vec3(red * 0.32, red * 0.24, red * 0.19);
        if (palette == 2) replacement = vec3(min(red * 1.05, 1.0), red * 0.65, red * 0.22);
        if (palette == 3) replacement = vec3(red * 0.78, red * 0.76, red * 0.71);
        c.rgb = mix(c.rgb, replacement, orange);
    }
    COLOR = c;
}
