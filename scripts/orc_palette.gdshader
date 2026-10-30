shader_type canvas_item;
uniform vec3 skin_tint : source_color = vec3(1.0);
uniform vec4 cloth_color : source_color = vec4(0.325,0.42,0.53,1.0);
uniform vec3 legacy_cloth_tint = vec3(1.0);
uniform bool iron_cloth = false;
uniform bool custom_head = false;
uniform float head_clear_up = -0.12;
uniform sampler2D faces_art : source_color, filter_linear_mipmap;
uniform sampler2D hair_art : source_color, filter_linear_mipmap;
uniform sampler2D facial_art : source_color, filter_linear_mipmap;
uniform int face_id = 0;
uniform int hair_id = -1;
uniform int beard_id = -1;
uniform int mustache_id = -1;
uniform vec4 hair_color : source_color = vec4(0.15,0.14,0.13,1.0);
uniform vec4 head_box = vec4(214,110,84,84);
uniform vec2 body_size = vec2(2048,1792);
uniform int head_direction = 0;
varying vec4 vertex_color;
void vertex() { vertex_color = COLOR; }
vec4 over(vec4 below, vec4 above) {
    float a = above.a + below.a*(1.0-above.a);
    return vec4((above.rgb*above.a+below.rgb*below.a*(1.0-above.a))/max(a,0.0001),a);
}
vec4 hair_shade(vec4 c) {
    float l=dot(c.rgb,vec3(0.299,0.587,0.114));
    c.rgb=hair_color.rgb*(0.25+l*3.0);
    return c;
}
vec4 layer(sampler2D art,vec2 p,vec4 region) {
    if(p.x<0.0 || p.y<0.0 || p.x>1.0 || p.y>1.0) return vec4(0.0);
    return texture(art,region.xy+p*region.zw);
}
void fragment() {
    vec4 c = texture(TEXTURE, UV);
    float warm = smoothstep(0.02,0.09,c.g-c.b) * smoothstep(0.68,0.85,c.g/max(c.r,0.01));
    float skin = warm * smoothstep(0.16,0.30,c.r) * (1.0-smoothstep(0.86,0.98,c.r));
    float cloth = smoothstep(0.015,0.05,c.b-c.r) * smoothstep(0.015,0.05,c.b-c.g);
    if(iron_cloth) cloth=smoothstep(0.04,0.14,c.r-c.g)*smoothstep(0.04,0.14,c.r-c.b)*(1.0-smoothstep(0.5,0.7,c.g/max(c.r,0.01)));
    float shade=dot(c.rgb,vec3(0.299,0.587,0.114));
    if(custom_head) {
        c.rgb=mix(c.rgb,cloth_color.rgb*shade*2.8,cloth);
        c.rgb*=mix(vec3(1.0),skin_tint,skin);
    } else {
        float legacy_skin=smoothstep(0.02,0.09,c.g-c.b)*smoothstep(0.50,0.77,c.g/max(c.r,0.01))*smoothstep(0.16,0.30,c.r)*(1.0-smoothstep(0.86,0.98,c.r));
        float legacy_cloth=smoothstep(0.015,0.05,c.b-c.r)*smoothstep(0.015,0.05,c.b-c.g);
        c.rgb*=mix(vec3(1.0),skin_tint,legacy_skin);
        c.rgb*=mix(vec3(1.0),legacy_cloth_tint,legacy_cloth);
    }
    if(custom_head) {
        vec2 q=(UV*body_size-head_box.xy)/head_box.zw;
        bool rear=head_direction==3;
        float col=head_direction==0?0.0:(rear?2.0:1.0);
        if(head_direction==2) q.x=1.0-q.x;
        // All appearance pieces are registered within each full-body pose.
        // The existing body/weapon animation and its foot anchors are untouched.
        vec4 face=layer(faces_art,q,vec4(col/3.0,float(face_id)/3.0,1.0/3.0,1.0/3.0));
        face.rgb*=skin_tint;
        if(rear && q.y>0.36) face.a=0.0; // collar occludes the neck from behind
        if(q.x>(head_clear_up< -0.2 ? -0.4 : 0.08) && q.x<(head_clear_up< -0.2 ? 1.5 : 1.05) && q.y>head_clear_up && q.y<0.22 && max(c.r,max(c.g,c.b))<0.28) c.a=0.0; // old topknot
        c=over(c,face);
        if(hair_id>=0) c=over(c,hair_shade(layer(hair_art,q,vec4(col/3.0,float(hair_id)/3.0,1.0/3.0,1.0/3.0))));
        if(!rear) {
            float side=head_direction==0?0.0:1.0;
            if(beard_id>=0) {
                vec2 b=(q-vec2(side==0.0?0.23:0.10,0.56))/vec2(0.56,beard_id==0?0.30:0.63);
                // Measured artwork regions; generation did not obey equal row heights.
                vec4 r=beard_id==0?vec4(side==0.0?0.174:0.63,0.03,side==0.0?0.23:0.19,0.19):vec4(side==0.0?0.195:0.634,0.235,0.18,0.325);
                c=over(c,hair_shade(layer(facial_art,b,r)));
            }
            if(mustache_id>=0) {
                vec2 m=(q-vec2(side==0.0?0.22:0.075,0.60))/vec2(0.59,mustache_id==0?0.23:0.49);
                vec4 r=mustache_id==0?vec4(side==0.0?0.115:0.66,0.57,side==0.0?0.35:0.22,0.15):vec4(side==0.0?0.16:0.645,0.735,side==0.0?0.27:0.17,0.25);
                c=over(c,hair_shade(layer(facial_art,m,r)));
            }
        }
    }
    COLOR = c * vertex_color;
}
