uniform sampler2D tex0;
uniform vec2 iResolution;

const float radius = 11.0;             // Radius of the blur
const float sigmaColor = 12.0;         // Variance for color weighting
const float sigmaSpace = 20.0;         // Variance for space weighting

float gaussian(float x, float sigma) {
    return exp(-0.5 * (x * x) / (sigma * sigma)) / (2.0 * 3.14159265 * sigma * sigma);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, abs(1.0 - uv.y));

    vec2 texelSize = 1.0 / iResolution;  // Size of one texel
    vec3 centerColor = texture(tex0, uv).rgb;
    
    float sumWeights = 0.0;
    vec3 finalColor = vec3(0.0);
    
    for (int x = -int(radius); x <= int(radius); x++) {
        for (int y = -int(radius); y <= int(radius); y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            vec3 sampleColor = texture(tex0, uv + offset).rgb;
            
            // spatial weight based on distance
            float spaceWeight = gaussian(length(vec2(x, y)), sigmaSpace);
            
            // color weight based on color difference
            float colorWeight = gaussian(length(sampleColor - centerColor), sigmaColor);
            
            float weight = spaceWeight * colorWeight;
            
            finalColor += sampleColor * weight;
            sumWeights += weight;
        }
    }
    
    finalColor /= sumWeights;
    
    fragColor = vec4(finalColor, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
