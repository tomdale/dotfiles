// -----------------------------------------------------------------------------
// Theme Configuration
// -----------------------------------------------------------------------------

#define THEME_AURORA 0
#define THEME_CATPPUCCIN 1
#define THEME_DRACULA 2
#define THEME_NORD 3
#define THEME_GRUVBOX 4
#define THEME_TOKYO_NIGHT 5
#define THEME_TRON 6
#define THEME_SYNTHWAVE 7
#define THEME_MONOKAI 8

// CHANGE THIS VALUE TO SWITCH THEMES
#define ACTIVE_THEME THEME_AURORA

// -----------------------------------------------------------------------------
// Settings
// -----------------------------------------------------------------------------

const float SPEED = 0.1;
const float CORNER_RADIUS = 0.3;
const float DECAY_START = 0.1;
const float DECAY_RATE = 8.0;

// Rectangular Cutoff Settings
const float GLOW_CUTOFF_DISTANCE = 0.3;
const float GLOW_CUTOFF_SOFTNESS = 0.5;

// Dithering Strength
const float DITHER_STRENGTH = 1.0 / 50.0;

// Opacity settings
const float GLOW_OPACITY = 1.0;

// Snake head/tail proportions
const float HEAD_END = 0.4;
const float TAIL_END = 0.4;

const float PI = 3.14159265358;

// -----------------------------------------------------------------------------
// Color Palette Configuration
// -----------------------------------------------------------------------------

// 1. Aurora Palette
const int AURORA_NUM_STOPS = 4;
const float AURORA_BRIGHTNESS = 0.8;
const vec3 AURORA_GREEN  = vec3(0.203, 0.658, 0.325);
const vec3 AURORA_YELLOW = vec3(0.984, 0.737, 0.019);
const vec3 AURORA_RED    = vec3(0.917, 0.262, 0.207);
const vec3 AURORA_BLUE   = vec3(0.258, 0.521, 0.956);

// 2. Catppuccin Mocha Palette
const int CAT_NUM_STOPS = 6;
const float CAT_BRIGHTNESS = 0.6;
const vec3 CAT_LAVENDER = vec3(0.706, 0.745, 0.996);
const vec3 CAT_SAPPHIRE = vec3(0.455, 0.780, 0.925);
const vec3 CAT_GREEN    = vec3(0.651, 0.890, 0.631);
const vec3 CAT_YELLOW   = vec3(0.976, 0.886, 0.686);
const vec3 CAT_RED      = vec3(0.953, 0.545, 0.659);
const vec3 CAT_MAUVE    = vec3(0.796, 0.651, 0.969);

// 3. Dracula Palette
const int DRAC_NUM_STOPS = 5;
const float DRAC_BRIGHTNESS = 0.75;
const vec3 DRAC_PURPLE = vec3(0.741, 0.576, 0.976);
const vec3 DRAC_PINK   = vec3(1.000, 0.475, 0.776);
const vec3 DRAC_RED    = vec3(1.000, 0.333, 0.333);
const vec3 DRAC_YELLOW = vec3(0.945, 0.980, 0.549);
const vec3 DRAC_GREEN  = vec3(0.314, 0.980, 0.482);

// 4. Nord Palette
const int NORD_NUM_STOPS = 4;
const float NORD_BRIGHTNESS = 0.85;
const vec3 NORD_POLAR1 = vec3(0.561, 0.737, 0.733);
const vec3 NORD_POLAR2 = vec3(0.533, 0.753, 0.816);
const vec3 NORD_POLAR3 = vec3(0.506, 0.631, 0.757);
const vec3 NORD_POLAR4 = vec3(0.369, 0.506, 0.675);

// 5. Gruvbox Dark Palette
const int GRUV_NUM_STOPS = 5;
const float GRUV_BRIGHTNESS = 0.7;
const vec3 GRUV_RED    = vec3(0.984, 0.286, 0.204);
const vec3 GRUV_YELLOW = vec3(0.980, 0.741, 0.184);
const vec3 GRUV_GREEN  = vec3(0.722, 0.733, 0.149);
const vec3 GRUV_AQUA   = vec3(0.553, 0.761, 0.627);
const vec3 GRUV_ORANGE = vec3(0.996, 0.502, 0.188);

// 6. Tokyo Night Palette
const int TOKYO_NUM_STOPS = 5;
const float TOKYO_BRIGHTNESS = 0.8;
const vec3 TOKYO_BLUE    = vec3(0.478, 0.635, 0.969);
const vec3 TOKYO_CYAN    = vec3(0.490, 0.812, 1.000);
const vec3 TOKYO_MAGENTA = vec3(0.733, 0.604, 0.969);
const vec3 TOKYO_GREEN   = vec3(0.620, 0.808, 0.416);
const vec3 TOKYO_TEAL    = vec3(0.106, 0.800, 0.765);

// 7. TRON Legacy Palette
// Uses a "hot white" center to mimic a light cycle jet wall
const int TRON_NUM_STOPS = 5;
const float TRON_BRIGHTNESS = 1.0; 
const vec3 TRON_BLUE_DARK = vec3(0.000, 0.235, 0.718); // Deep Blue
const vec3 TRON_CYAN      = vec3(0.435, 0.765, 0.875); // Legacy Cyan
const vec3 TRON_WHITE     = vec3(0.950, 0.980, 1.000); // Core White
const vec3 TRON_ORANGE    = vec3(1.000, 0.620, 0.100); // Clu Orange (Accent)

// 8. Synthwave / Outrun Palette
const int SYNTH_NUM_STOPS = 5;
const float SYNTH_BRIGHTNESS = 0.9;
const vec3 SYNTH_PURPLE = vec3(0.200, 0.050, 0.300);
const vec3 SYNTH_PINK   = vec3(1.000, 0.000, 0.500); // Hot Pink
const vec3 SYNTH_ORANGE = vec3(1.000, 0.500, 0.000);
const vec3 SYNTH_YELLOW = vec3(1.000, 0.900, 0.000);
const vec3 SYNTH_CYAN   = vec3(0.000, 0.900, 1.000);

// 9. Monokai Palette
const int MONO_NUM_STOPS = 5;
const float MONO_BRIGHTNESS = 0.8;
const vec3 MONO_PINK   = vec3(0.976, 0.149, 0.447); // #F92672
const vec3 MONO_GREEN  = vec3(0.651, 0.886, 0.180); // #A6E22E
const vec3 MONO_YELLOW = vec3(0.902, 0.863, 0.451); // #E6DB74
const vec3 MONO_ORANGE = vec3(0.992, 0.588, 0.098); // #FD971F
const vec3 MONO_BLUE   = vec3(0.400, 0.851, 0.937); // #66D9EF

// -----------------------------------------------------------------------------
// Theme Selection Logic
// -----------------------------------------------------------------------------

#if ACTIVE_THEME == THEME_CATPPUCCIN
    const int NUM_STOPS = CAT_NUM_STOPS;
    const float BRIGHTNESS = CAT_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_DRACULA
    const int NUM_STOPS = DRAC_NUM_STOPS;
    const float BRIGHTNESS = DRAC_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_NORD
    const int NUM_STOPS = NORD_NUM_STOPS;
    const float BRIGHTNESS = NORD_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_GRUVBOX
    const int NUM_STOPS = GRUV_NUM_STOPS;
    const float BRIGHTNESS = GRUV_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_TOKYO_NIGHT
    const int NUM_STOPS = TOKYO_NUM_STOPS;
    const float BRIGHTNESS = TOKYO_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_TRON
    const int NUM_STOPS = TRON_NUM_STOPS;
    const float BRIGHTNESS = TRON_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_SYNTHWAVE
    const int NUM_STOPS = SYNTH_NUM_STOPS;
    const float BRIGHTNESS = SYNTH_BRIGHTNESS;
#elif ACTIVE_THEME == THEME_MONOKAI
    const int NUM_STOPS = MONO_NUM_STOPS;
    const float BRIGHTNESS = MONO_BRIGHTNESS;
#else
    const int NUM_STOPS = AURORA_NUM_STOPS;
    const float BRIGHTNESS = AURORA_BRIGHTNESS;
#endif

// MAX_COLORS must be large enough to hold the largest palette
const int MAX_COLORS = 6;

vec3 colors[MAX_COLORS];
float positions[MAX_COLORS];

void initGradient() {
    #if ACTIVE_THEME == THEME_CATPPUCCIN
        colors[0] = CAT_LAVENDER; positions[0] = 0.15;
        colors[1] = CAT_SAPPHIRE; positions[1] = 0.30;
        colors[2] = CAT_GREEN;    positions[2] = 0.45;
        colors[3] = CAT_YELLOW;   positions[3] = 0.60;
        colors[4] = CAT_RED;      positions[4] = 0.75;
        colors[5] = CAT_MAUVE;    positions[5] = 0.90;

    #elif ACTIVE_THEME == THEME_DRACULA
        colors[0] = DRAC_PURPLE; positions[0] = 0.20;
        colors[1] = DRAC_PINK;   positions[1] = 0.35;
        colors[2] = DRAC_RED;    positions[2] = 0.50;
        colors[3] = DRAC_YELLOW; positions[3] = 0.65;
        colors[4] = DRAC_GREEN;  positions[4] = 0.80;
        colors[5] = vec3(0.0);   positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_NORD
        colors[0] = NORD_POLAR4; positions[0] = 0.20;
        colors[1] = NORD_POLAR3; positions[1] = 0.40;
        colors[2] = NORD_POLAR2; positions[2] = 0.60;
        colors[3] = NORD_POLAR1; positions[3] = 0.80;
        colors[4] = vec3(0.0);   positions[4] = 1.0;
        colors[5] = vec3(0.0);   positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_GRUVBOX
        colors[0] = GRUV_RED;    positions[0] = 0.15;
        colors[1] = GRUV_ORANGE; positions[1] = 0.30;
        colors[2] = GRUV_YELLOW; positions[2] = 0.50;
        colors[3] = GRUV_GREEN;  positions[3] = 0.70;
        colors[4] = GRUV_AQUA;   positions[4] = 0.85;
        colors[5] = vec3(0.0);   positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_TOKYO_NIGHT
        colors[0] = TOKYO_MAGENTA; positions[0] = 0.15;
        colors[1] = TOKYO_BLUE;    positions[1] = 0.35;
        colors[2] = TOKYO_CYAN;    positions[2] = 0.50;
        colors[3] = TOKYO_TEAL;    positions[3] = 0.65;
        colors[4] = TOKYO_GREEN;   positions[4] = 0.80;
        colors[5] = vec3(0.0);     positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_TRON
        // Gradient: Blue -> Cyan -> White -> Cyan -> Blue
        // Creates a "glowing core" effect
        colors[0] = TRON_BLUE_DARK; positions[0] = 0.20;
        colors[1] = TRON_CYAN;      positions[1] = 0.40;
        colors[2] = TRON_WHITE;     positions[2] = 0.50; // Hot center
        colors[3] = TRON_CYAN;      positions[3] = 0.60;
        colors[4] = TRON_BLUE_DARK; positions[4] = 0.80;
        colors[5] = vec3(0.0);      positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_SYNTHWAVE
        // Gradient: Purple -> Pink -> Orange -> Yellow
        colors[0] = SYNTH_PURPLE; positions[0] = 0.15;
        colors[1] = SYNTH_PINK;   positions[1] = 0.40;
        colors[2] = SYNTH_ORANGE; positions[2] = 0.65;
        colors[3] = SYNTH_YELLOW; positions[3] = 0.80;
        colors[4] = SYNTH_CYAN;   positions[4] = 0.95; // Grid accent
        colors[5] = vec3(0.0);    positions[5] = 1.0;

    #elif ACTIVE_THEME == THEME_MONOKAI
        colors[0] = MONO_PINK;   positions[0] = 0.20;
        colors[1] = MONO_ORANGE; positions[1] = 0.40;
        colors[2] = MONO_YELLOW; positions[2] = 0.60;
        colors[3] = MONO_GREEN;  positions[3] = 0.80;
        colors[4] = MONO_BLUE;   positions[4] = 0.95;
        colors[5] = vec3(0.0);   positions[5] = 1.0;

    #else
        // Aurora
        colors[0] = AURORA_GREEN;  positions[0] = 0.2;
        colors[1] = AURORA_YELLOW; positions[1] = 0.3;
        colors[2] = AURORA_RED;    positions[2] = 0.4;
        colors[3] = AURORA_BLUE;   positions[3] = 0.6;
        colors[4] = vec3(0.0);     positions[4] = 1.0;
        colors[5] = vec3(0.0);     positions[5] = 1.0;
    #endif
}

// -----------------------------------------------------------------------------
// Math & Utility Helpers
// -----------------------------------------------------------------------------

// High-frequency pseudo-random noise
float interleavedGradientNoise(vec2 n) {
  return fract(52.9829189 * fract(0.06711056 * n.x + 0.00583715 * n.y));
}

// Signed Distance Function for a rounded box
float sdRoundedBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// -----------------------------------------------------------------------------
// Geometry & Coordinates
// -----------------------------------------------------------------------------

struct GeometryData {
  vec2 center;
  float dist; // Distance to the box edge
};

// Calculates the centered coordinates, box size, and SDF distance
GeometryData getGeometry(vec2 uv, vec2 resolution) {
  float aspect = resolution.x / resolution.y;
  
  // Center coordinates with aspect correction
  vec2 center = uv - 0.5;
  center.x *= aspect;
  
  // Define box dimensions
  vec2 boxSize = vec2(0.5 * aspect, 0.5) - 0.02; 
  
  float d = sdRoundedBox(center, boxSize, CORNER_RADIUS);
  
  return GeometryData(center, d);
}

// -----------------------------------------------------------------------------
// Color Logic (The Snake)
// -----------------------------------------------------------------------------

vec4 getSnakeGradientColor(float t) {
    vec3 finalColor = vec3(0.0);
    
    // 1. Handle the "Head" (before first stop)
    float isHead = 1.0 - step(positions[0], t);
    finalColor += colors[0] * isHead;

    // 2. Handle the "Body" (Interpolation between stops)
    for (int i = 0; i < NUM_STOPS - 1; i++) {
        float startPos = positions[i];
        float endPos = positions[i+1];
        
        float inSegment = step(startPos, t) * (1.0 - step(endPos, t));
        
        float mixFactor = smoothstep(startPos, endPos, t);
        vec3 segmentColor = mix(colors[i], colors[i+1], mixFactor);
        
        finalColor += segmentColor * inSegment;
    }

    // 3. Handle the "Tail" (after last stop)
    float isTail = step(positions[NUM_STOPS - 1], t);
    finalColor += colors[NUM_STOPS - 1] * isTail;

    // Head and tail transparency (Global fade)
    float headFade = smoothstep(0.0, HEAD_END, t);
    float tailFade = 1.0 - smoothstep((1.0 - TAIL_END), 1.0, t);
    float alpha = headFade * tailFade;

    return vec4(finalColor, alpha);
}

// Calculates the final snake color vector based on position and time
vec4 calculateSnakeLayer(vec2 centerPos, float time) {
  float angle = atan(centerPos.y, centerPos.x);
  float normAngle = fract((angle / (PI * 2.0)) + 0.5 - (time * SPEED));
  return getSnakeGradientColor(normAngle);
}

// -----------------------------------------------------------------------------
// Glow Intensity Math
// -----------------------------------------------------------------------------

float calculateGlowIntensity(float dist) {
  // Exponential light decay
  float distanceField = dist - DECAY_START;
  float intensity = exp(min(distanceField, 0.0) * DECAY_RATE);
  
  // Safe Zone (Rectangular Cutoff)
  float cutoff = -GLOW_CUTOFF_DISTANCE;
  float safeZoneMask = smoothstep(cutoff, cutoff + GLOW_CUTOFF_SOFTNESS, dist);
  
  return intensity * safeZoneMask;
}

// -----------------------------------------------------------------------------
// Post-Processing & Compositing
// -----------------------------------------------------------------------------

vec3 applyDither(vec3 color, vec2 fragCoord) {
  float noise = (interleavedGradientNoise(fragCoord) - 0.5) * DITHER_STRENGTH;
  return color + noise;
}

vec3 compositeLayer(vec4 terminalPixel, vec3 snakeColor, float snakeAlpha) {
  // Determine if the current pixel is "background" (dark) or "text" (bright)
  float isBackground = 1.0 - step(0.5, dot(terminalPixel.rgb, vec3(1.0)));

  // Mix the terminal background with the glow
  vec3 backgroundWithGlow = mix(terminalPixel.rgb, snakeColor, snakeAlpha * GLOW_OPACITY);

  // Only apply glow to background pixels, keep text crisp
  return mix(terminalPixel.rgb, backgroundWithGlow, isBackground);
}


// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  // Initialize the gradient colors
  initGradient();

  vec2 uv = fragCoord.xy / iResolution.xy;
  
  // Calculate Geometry & SDF
  GeometryData geo = getGeometry(uv, iResolution.xy);
  
  // Calculate Glow Intensity (Mask)
  float glowIntensity = calculateGlowIntensity(geo.dist);
  
  // Calculate Snake Color and Alpha
  vec4 snakeLayer = calculateSnakeLayer(geo.center, iTime);
  
  // Combine base alpha with intensity and brightness
  float finalSnakeAlpha = snakeLayer.a * glowIntensity * BRIGHTNESS;
  vec3 snakeRGB = snakeLayer.rgb;

  // Apply Dithering
  snakeRGB = applyDither(snakeRGB, fragCoord);
  
  // Composite with Terminal Texture
  vec4 terminalColor = texture(iChannel0, uv);
  vec3 finalColor = compositeLayer(terminalColor, snakeRGB, finalSnakeAlpha);

  // Output
  fragColor = vec4(finalColor, terminalColor.a);
}
