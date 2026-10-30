shader_type canvas_item;
uniform sampler2D earth_texture : source_color, repeat_enable, filter_linear;
uniform sampler2D terrain_mask : filter_linear, repeat_disable;
varying vec2 world_uv;
void vertex() { world_uv=VERTEX/vec2(3584.0,1408.0); }
void fragment() {
    vec2 p=world_uv*vec2(3584.0,1408.0);
    vec2 bend=vec2(sin(p.y*0.063)+sin(p.x*0.071),cos(p.x*0.079)+cos(p.y*0.047))*4.0;
    vec4 mask=texture(terrain_mask,world_uv+bend/vec2(3584.0,1408.0));
    vec3 grass=texture(TEXTURE,UV).rgb*vec3(0.58,0.63,0.50);
    vec3 earth=texture(earth_texture,p/640.0).rgb*vec3(0.66,0.62,0.51);
    float amount=smoothstep(0.13,0.80,mask.r);
    vec3 surface=mix(grass,earth,amount);
    surface=mix(surface,vec3(0.12,0.20,0.22),smoothstep(0.2,0.8,mask.g));
    COLOR=vec4(surface,1.0);
}
