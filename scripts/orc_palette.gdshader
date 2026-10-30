shader_type canvas_item;
uniform vec3 skin_tint : source_color = vec3(1.0);
uniform vec3 cloth_tint : source_color = vec3(1.0);
varying vec4 vertex_color;
void vertex() { vertex_color = COLOR; }
void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float warm = smoothstep(0.02,0.09,c.g-c.b) * smoothstep(0.50,0.77,c.g/max(c.r,0.01));
    float skin = warm * smoothstep(0.16,0.30,c.r) * (1.0-smoothstep(0.86,0.98,c.r));
    float cloth = smoothstep(0.015,0.05,c.b-c.r) * smoothstep(0.015,0.05,c.b-c.g);
    c.rgb *= mix(vec3(1.0),skin_tint,skin);
    c.rgb *= mix(vec3(1.0),cloth_tint,cloth);
    COLOR = c * vertex_color;
}
