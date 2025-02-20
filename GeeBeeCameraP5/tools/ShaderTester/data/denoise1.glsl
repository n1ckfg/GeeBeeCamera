uniform sampler2D tex0;
uniform vec2 iResolution;

const float noiseThreshold = 10.1;
const float sharpness = 100.0;
const vec2 texelSize = vec2(1.0, 8.0);

vec3 RGBToYCoCg(vec3 rgb) {
    float Y = rgb.r * 0.25 + rgb.g * 0.5 + rgb.b * 0.25;
    float Co = rgb.r * 0.5 - rgb.b * 0.5;
    float Cg = -rgb.r * 0.25 + rgb.g * 0.5 - rgb.b * 0.25;
    return vec3(Y, Co, Cg);
}

vec3 YCoCgToRGB(vec3 YCoCg) {
    float R = YCoCg.x + YCoCg.y - YCoCg.z;
    float G = YCoCg.x + YCoCg.z;
    float B = YCoCg.x - YCoCg.y - YCoCg.z;
    return vec3(R, G, B);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, abs(1.0 - uv.y));

    vec2 offsets[9] = vec2[](
        vec2(-1, 1), vec2(0, 1), vec2(1, 1),
        vec2(-1, 0), vec2(0, 0), vec2(1, 0),
        vec2(-1, -1), vec2(0, -1), vec2(1, -1)
    );

    vec3 sampleColors[9];
    vec3 centerColor = RGBToYCoCg(texture(tex0, uv).rgb);

    for (int i = 0; i < 9; i++) {
        vec2 sampleCoords = uv + offsets[i] * texelSize;
        sampleColors[i] = RGBToYCoCg(texture(tex0, sampleCoords).rgb);
    }

    vec3 avgColor = vec3(0.0);
    float totalWeight = 0.0;

    for (int i = 0; i < 9; i++) {
        float colorDist = distance(centerColor, sampleColors[i]);
        float weight = 1.0 - smoothstep(0.0, noiseThreshold, colorDist);
        weight = pow(weight, sharpness);

        avgColor += sampleColors[i] * weight;
        totalWeight += weight;
    }

    avgColor /= totalWeight;

    vec3 finalColor = mix(centerColor, avgColor, smoothstep(0.0, noiseThreshold, length(avgColor - centerColor)));
    fragColor = vec4(YCoCgToRGB(finalColor), 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
