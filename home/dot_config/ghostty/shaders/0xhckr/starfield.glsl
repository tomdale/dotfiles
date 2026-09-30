// Vercel-agent-inspired Shadertoy shader for Ghostty.
// A ten-LED triangular array with soft RGB bloom and a restrained star field.

vec2 ledCentre(int index) {
    // Ten lights, from the apex down through four rows.
    if (index == 0) return vec2(0.00, 0.18);
    if (index == 1) return vec2(-0.07, 0.08);
    if (index == 2) return vec2(0.07, 0.08);
    if (index == 3) return vec2(-0.14, -0.02);
    if (index == 4) return vec2(0.00, -0.02);
    if (index == 5) return vec2(0.14, -0.02);
    if (index == 6) return vec2(-0.21, -0.12);
    if (index == 7) return vec2(-0.07, -0.12);
    if (index == 8) return vec2(0.07, -0.12);
    return vec2(0.21, -0.12);
}

vec3 ledColour(int index) {
    // Three colour families, blended spatially like the hero's edge lights.
    if (index == 0 || index == 1 || index == 6) {
        return vec3(1.0, 0.055, 0.08);
    }
    if (index == 2 || index == 3 || index == 7) {
        return vec3(0.03, 0.9, 0.22);
    }
    return vec3(0.08, 0.3, 1.0);
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float star(vec2 uv) {
    vec2 cell = floor(uv);
    vec2 local = fract(uv) - 0.5;
    float radius = 0.022 + hash21(cell) * 0.035;
    float brightness = smoothstep(radius, 0.0, length(local));
    float phase = hash21(cell + 17.0);
    return brightness * (0.72 + 0.28 * sin(iTime * 0.7 + phase * 6.28318));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // Nearly-black blue-grey backdrop, with a soft centre lift.
    float vignette = 1.0 - 0.45 * smoothstep(0.12, 0.82, length(p));
    vec3 color = vec3(0.008, 0.011, 0.022) * vignette;

    // A dim star field echoes the original shader without overpowering the LEDs.
    color += vec3(0.18, 0.25, 0.48) * star(p * 24.0) * 0.11;

    // Triangle-shaped coloured ambient pools behind the emitters.
    color += vec3(0.10, 0.008, 0.012) * exp(-18.0 * length(p - vec2(-0.10, 0.02)));
    color += vec3(0.006, 0.09, 0.025) * exp(-18.0 * length(p - vec2(0.00, -0.04)));
    color += vec3(0.008, 0.02, 0.12) * exp(-18.0 * length(p - vec2(0.10, 0.02)));

    for (int index = 0; index < 10; index++) {
        vec2 centre = ledCentre(index);
        float phase = hash21(vec2(float(index), 9.0));
        float pulse = 0.82 + 0.18 * sin(iTime * (0.45 + phase * 0.2) + phase * 6.28318);
        float distanceFromLed = length(p - centre);
        float bloom = pow(max(0.0, 1.0 - distanceFromLed / 0.12), 3.0);
        float dotMask = 1.0 - smoothstep(0.010, 0.006, distanceFromLed);
        vec3 emission = ledColour(index) * pulse;

        color += emission * bloom * 0.20;
        color += emission * dotMask * 0.72;
    }

    // Ghostty supplies the rendered terminal as Shadertoy's iChannel0.
    vec4 terminal = texture(iChannel0, uv);
    float backgroundLuma = dot(iBackgroundColor, vec3(0.2126, 0.7152, 0.0722));
    float terminalLuma = dot(terminal.rgb, vec3(0.2126, 0.7152, 0.0722));

    // Keep foreground glyphs while replacing the terminal's flat background.
    float brightGlyph = smoothstep(0.38, 0.82, terminalLuma);
    float darkGlyph = 1.0 - smoothstep(0.12, 0.55, terminalLuma);
    float glyph = mix(brightGlyph, darkGlyph, step(0.5, backgroundLuma));
    color = mix(color, terminal.rgb, glyph);

    fragColor = vec4(color, 1.0);
}
