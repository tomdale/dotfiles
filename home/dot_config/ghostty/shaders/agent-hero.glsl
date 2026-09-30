// Single-pass Shadertoy port of Vercel's Agent hero shader (front#82102).
// Ghostty provides no auxiliary atlas/grain textures or mouse input, so the
// original baked light transport and pointer are reproduced analytically.

const float TERMINAL_BACKGROUND_THRESHOLD = 0.15;
const float DOT_SPACING = 0.044;
const float DOT_VERTICAL_SPACING = 0.03784;
const float DOT_RADIUS = 0.010;
const float PEAK_RADIANCE = 8.5;
const float BACKDROP_ALBEDO = 0.075;
const float AMBIENT = 0.004;
const float MAX_DISTORTION = 0.016875;

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

float hash21(vec2 value) {
    vec3 p = fract(vec3(value.xyx) * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

vec2 hash22(vec2 value) {
    return vec2(hash21(value), hash21(value + vec2(19.19, 7.73)));
}

vec2 dotCentre(int index) {
    int row;
    int column;
    if (index < 1) {
        row = 0;
        column = index;
    } else if (index < 3) {
        row = 1;
        column = index - 1;
    } else if (index < 6) {
        row = 2;
        column = index - 3;
    } else {
        row = 3;
        column = index - 6;
    }
    return vec2(
        (float(column) - float(row) * 0.5) * DOT_SPACING,
        (1.5 - float(row)) * DOT_VERTICAL_SPACING
    );
}

float reachCompensation(int index) {
    if (index == 0) return 0.250;
    if (index == 1) return 0.200;
    if (index == 2) return 0.270;
    if (index == 3) return 0.185;
    if (index == 4) return 0.285;
    if (index == 5) return 0.255;
    if (index == 6) return 0.250;
    if (index == 7) return 0.330;
    if (index == 8) return 0.300;
    return 0.290;
}

float edgeWeight(vec2 point, vec2 edgeCentre, float radius) {
    return pow(1.0 / (1.0 + distance(point, edgeCentre) / radius), 3.0);
}

vec3 linearLightColor(int index) {
    // Exact linear-RGB edge colors from the homepage implementation.
    const vec3 edgeRed = vec3(0.896269, 0.027321, 0.051269);
    const vec3 edgeGreen = vec3(0.0, 0.407240, 0.048172);
    const vec3 edgeBlue = vec3(0.0, 0.278894, 1.0);
    const vec2 redCentre = vec2(-0.04625, 0.001875);
    const vec2 greenCentre = vec2(0.0, -0.08125);
    const vec2 blueCentre = vec2(0.04625, 0.001875);
    const float radius = 0.133;

    vec2 centre = dotCentre(index);
    float red = edgeWeight(centre, redCentre, radius);
    float green = edgeWeight(centre, greenCentre, radius);
    float blue = edgeWeight(centre, blueCentre, radius);
    vec3 blended = (edgeRed * red + edgeGreen * green + edgeBlue * blue) /
        max(red + green + blue, 0.0001);
    return blended / max(luminance(blended), 0.0001) * reachCompensation(index);
}

float signedEdgeDistance(vec2 start, vec2 end, vec2 point) {
    vec2 edge = end - start;
    vec2 relative = point - start;
    return (edge.x * relative.y - edge.y * relative.x) / length(edge);
}

float distanceOutsideProtectedTriangle(vec2 point) {
    const vec2 bottomLeft = vec2(-0.0925, -0.08125);
    const vec2 bottomRight = vec2(0.0925, -0.08125);
    const vec2 top = vec2(0.0, 0.085);
    float bottom = signedEdgeDistance(bottomLeft, bottomRight, point);
    float right = signedEdgeDistance(bottomRight, top, point);
    float left = signedEdgeDistance(top, bottomLeft, point);
    return max(0.0, -min(bottom, min(right, left)));
}

vec2 virtualPointer(float time) {
    // Ghostty does not expose iMouse. This Lissajous path repeatedly enters,
    // crosses, pauses near, and leaves the original 120px hover radius.
    float t = time * 0.19;
    return vec2(
        sin(t * 1.13) + 0.32 * sin(t * 2.41 + 1.4),
        cos(t * 0.83 + 0.5) + 0.28 * sin(t * 1.97)
    ) * vec2(0.105, 0.090);
}

float analyticLightTransport(vec2 point, vec2 centre) {
    // Approximate the PR's pre-baked irradiance atlas: a tight contact pool
    // riding over a broad, inverse-square-like floor response.
    float radialDistance = distance(point, centre);
    float contact = exp(-radialDistance * 42.0);
    float broad = 1.0 / (1.0 + pow(radialDistance / 0.16, 2.35));
    return min(4.25, contact * 2.1 + broad * 1.35);
}

float columnShadow(vec2 point, vec2 lightPosition, vec2 blockerPosition) {
    vec2 ray = point - lightPosition;
    float rayLength = length(ray);
    if (rayLength < 0.0001) return 1.0;

    vec2 direction = ray / rayLength;
    float blockerDepth = dot(blockerPosition - lightPosition, direction);
    if (blockerDepth <= 0.0 || blockerDepth >= rayLength) return 1.0;

    vec2 nearestPoint = lightPosition + direction * blockerDepth;
    float missDistance = distance(blockerPosition, nearestPoint);
    float distanceBehindBlocker = rayLength - blockerDepth;

    // Model each LED as a short cylindrical column. A finite source radius
    // widens the penumbra in proportion to the receiver's distance behind it.
    const float columnRadius = 0.0115;
    const float sourceRadius = 0.0055;
    float penumbra = 0.0015 + sourceRadius * distanceBehindBlocker /
        max(blockerDepth, 0.018);
    float visibility = smoothstep(
        columnRadius - penumbra,
        columnRadius + penumbra,
        missDistance
    );

    // Preserve some colored bounce in the umbra, as in the baked atlas.
    return mix(0.16, 1.0, visibility);
}

vec3 tonemapNeutral(vec3 color) {
    float darkestChannel = min(color.r, min(color.g, color.b));
    float offset = darkestChannel < 0.08
        ? darkestChannel - 6.25 * darkestChannel * darkestChannel
        : 0.04;
    color -= offset;

    const float compressionStart = 0.76;
    float peak = max(color.r, max(color.g, color.b));
    if (peak < compressionStart) return color;
    float compressionRange = 1.0 - compressionStart;
    float compressedPeak = 1.0 - compressionRange * compressionRange /
        (peak + compressionRange - compressionStart);
    color *= compressedPeak / peak;
    float desaturation = 1.0 - 1.0 /
        (0.15 * (peak - compressedPeak) + 1.0);
    return mix(color, vec3(compressedPeak), desaturation);
}

vec3 applyPhotographicGrade(vec3 color) {
    color *= exp2(0.15);
    color = max(color - vec3(0.003), vec3(0.0));
    color = clamp(tonemapNeutral(color), 0.0, 1.0);
    color = (color - vec3(0.05)) * 1.05 + 0.05;
    return clamp(mix(vec3(luminance(color)), color, 1.31), 0.0, 1.0);
}

vec3 linearToSrgb(vec3 color) {
    vec3 low = color * 12.92;
    vec3 high = 1.055 * pow(max(color, vec3(0.0)), vec3(1.0 / 2.4)) - 0.055;
    return mix(high, low, lessThanEqual(color, vec3(0.0031308)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 point = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    // WebGL and Ghostty present the fragment coordinate's vertical axis in
    // opposite directions for this effect; flip it to preserve the website's
    // apex-at-top triangle orientation.
    point.y = -point.y;
    vec2 pointer = virtualPointer(iTime);

    // The virtual pointer selects a column; it is never itself a light source.
    // A sharp softmax keeps transitions smooth without allowing the source to
    // visibly wander away from the triangular LED array.
    vec2 sourcePosition = vec2(0.0);
    vec3 sourceColor = vec3(0.0);
    float sourceNormalization = 0.0;
    for (int index = 0; index < 10; index++) {
        vec2 centre = dotCentre(index);
        float selection = exp(-1800.0 * dot(pointer - centre, pointer - centre));
        sourcePosition += centre * selection;
        sourceColor += linearLightColor(index) * selection;
        sourceNormalization += selection;
    }
    sourcePosition /= max(sourceNormalization, 0.00000001);
    sourceColor /= max(sourceNormalization, 0.00000001);

    vec2 grain = hash22(floor(fragCoord * 0.5)) * 2.0 - 1.0;
    float distortion = sqrt(smoothstep(
        0.0,
        0.525,
        distanceOutsideProtectedTriangle(point)
    ));
    vec2 samplePoint = point + grain * MAX_DISTORTION * distortion;
    float sourceTransport = analyticLightTransport(samplePoint, sourcePosition);
    float shadow = 1.0;
    float occlusion = 0.0;
    float emitterMask = 0.0;
    vec3 emitter = vec3(0.0);

    for (int index = 0; index < 10; index++) {
        vec2 centre = dotCentre(index);
        float radialDistance = distance(point, centre);
        float sourceDistance = distance(sourcePosition, centre);

        // The selected emitting column cannot occlude itself. Every other
        // physical column casts a soft shadow away from that LED.
        float isSource = 1.0 - smoothstep(0.001, 0.008, sourceDistance);
        float blockerShadow = columnShadow(samplePoint, sourcePosition, centre);
        shadow = min(shadow, mix(blockerShadow, 1.0, isSource));
        occlusion = max(occlusion,
            exp(-radialDistance * 115.0) * 0.62 +
            exp(-radialDistance * 52.0) * 0.22 +
            exp(-radialDistance * 18.0) * 0.08
        );

        // All columns emit a dim floor light; the selected column reaches the
        // original hover weight of three and supplies the cast-shadow source.
        float weight = mix(0.03, 3.0, isSource);
        float signedDistance = radialDistance - DOT_RADIUS;
        float softness = max(fwidth(signedDistance), 0.001);
        float dotMask = 1.0 - smoothstep(-softness, softness, signedDistance);
        float radiance = PEAK_RADIANCE * pow(clamp(weight, 0.0, 4.0), 2.7);
        emitterMask = max(emitterMask, dotMask);
        emitter = max(emitter, linearLightColor(index) * radiance * dotMask);
    }

    float ambientOcclusion = clamp(1.0 - occlusion, 0.12, 1.0);
    vec3 irradiance = sourceTransport * shadow * sourceColor;
    float vignette = 1.0 - 0.42 * smoothstep(0.16, 0.72, length(point));
    vec3 color = BACKDROP_ALBEDO * vignette *
        (irradiance * ambientOcclusion + vec3(AMBIENT));

    // Emitters replace the floor rather than adding to it.
    color = mix(color, emitter, clamp(emitterMask, 0.0, 1.0));
    color = linearToSrgb(applyPhotographicGrade(color));

    // Match the original 4% multiplicative grain and 160px edge feather.
    float grainMultiplier = 1.0 + (hash21(floor(fragCoord)) * 2.0 - 1.0) * 0.04;
    color *= grainMultiplier;
    vec2 edgeDistance = min(uv, 1.0 - uv) * iResolution.xy / iResolution.y;
    color *= smoothstep(0.0, 0.20, min(edgeDistance.x, edgeDistance.y));

    // Preserve Ghostty's terminal foreground using the compositing contract
    // proven by the upstream 0xhckr shaders on this setup.
    vec4 terminal = texture(iChannel0, uv);
    float backgroundMask = 1.0 - step(
        TERMINAL_BACKGROUND_THRESHOLD,
        luminance(terminal.rgb)
    );
    vec3 composited = mix(terminal.rgb, color, backgroundMask);
    fragColor = vec4(composited, terminal.a);
}
