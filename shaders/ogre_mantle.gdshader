shader_type canvas_item;
// The mask belongs to the pose and is shared by all mantle materials. Holes
// keep the original hands, hair, weapon and exposed skin in front of the cloth.
uniform sampler2D coverage : filter_linear, repeat_disable;
uniform vec4 coverage_region;
uniform vec4 item_region;

void fragment() {
    vec2 panel_uv = clamp((UV - item_region.xy) / item_region.zw, vec2(0.0), vec2(1.0));
    vec4 mask = texture(coverage, coverage_region.xy + panel_uv * coverage_region.zw);
    COLOR.rgb *= mask.r;
    COLOR.a *= mask.a;
}
