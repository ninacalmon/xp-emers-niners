shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, specular_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest, repeat_disable;

instance uniform bool enable_billboard = true;
instance uniform bool billboard_y_only = true;
instance uniform bool outline_enabled = true;
instance uniform bool outline_only = true;
instance uniform float outline_depth_offset : hint_range(0.0, 1.0) = 0.00;

instance uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
instance uniform float glowSize : hint_range(0.0, 300.0) = 6.0;
instance uniform int glowDensity : hint_range(0, 30) = 3;
instance uniform int glowRadialCoverage : hint_range(0, 32) = 4;
instance uniform float glowAngle : hint_range(0.0, 6.28) = 1.0;
instance uniform float glowSharpness : hint_range(0.0, 5.0) = 0.0;
instance uniform float alphaThreshold : hint_range(0.0, 1.0) = 0.2;

void vertex() {
    if (enable_billboard) {
        float scale_x = length(MODEL_MATRIX[0].xyz);
        float scale_y = length(MODEL_MATRIX[1].xyz);
        float scale_z = length(MODEL_MATRIX[2].xyz);

        vec3 right = normalize(INV_VIEW_MATRIX[0].xyz);
        vec3 up = normalize(INV_VIEW_MATRIX[1].xyz);
        vec3 back = normalize(INV_VIEW_MATRIX[2].xyz);

        if (billboard_y_only) {
            vec3 flat_right = vec3(right.x, 0.0, right.z);
            float flat_len = length(flat_right);
            right = flat_len > 0.0001 ? flat_right / flat_len : vec3(1.0, 0.0, 0.0);
            up = vec3(0.0, 1.0, 0.0);
            back = cross(right, up);
        }

        MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
            vec4(right * scale_x, 0.0),
            vec4(up * scale_y, 0.0),
            vec4(back * scale_z, 0.0),
            MODEL_MATRIX[3]
        );
    }

    // Push the quad away from the camera so it renders behind the body sprite.
    if (outline_only) {
        MODELVIEW_MATRIX[3].z -= outline_depth_offset;
    }
}

void fragment() {
    vec4 col = texture(sprite_texture, UV);

    ALBEDO = col.rgb;
    ALPHA = col.a;

    if (outline_enabled) {
        vec2 pixel_size = 1.0 / vec2(textureSize(sprite_texture, 0));
        float alph = 0.0;
        for (int i = 0; i < glowRadialCoverage; i++) {
            for (int j = 0; j < glowDensity; j++) {
                float radians360 = 6.28;
                float angle = (radians360 / float(glowRadialCoverage)) * float(i + 1) + glowAngle;
                float dist = glowSize * float(j + 1) / float(glowDensity);
                vec2 pixel_coor = vec2(sin(angle), cos(angle));
                vec2 sample_uv = UV + pixel_coor * pixel_size * dist;

                float inside = step(0.0, sample_uv.x) * step(sample_uv.x, 1.0)
                             * step(0.0, sample_uv.y) * step(sample_uv.y, 1.0);

                vec4 tex = texture(sprite_texture, sample_uv);

                float distFrom = float(glowDensity - j) / float(glowDensity);
                float sharpness = mix(0.0, 1.0, pow(distFrom, glowSharpness));
                alph += (tex.a * line_color.a) * sharpness * inside;
            }
        }

        if (outline_only) {
            // Solid outline color; the body sprite in front covers the middle.
            ALBEDO = line_color.rgb;
            ALPHA = max(alph, col.a * line_color.a);
        } else if (ALPHA < alphaThreshold) {
            ALBEDO = line_color.rgb;
            ALPHA = alph;
        }
    } else if (outline_only) {
        // Outline disabled: hide this sprite completely.
        ALPHA = 0.0;
    }
}