uniform sampler2D u_texture;
uniform vec2 u_resolution;

float gaussian(float x, float sigma) {
    return exp(-(x * x) / (2.0 * sigma * sigma));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec3 color = texture2D(u_texture, uv).rgb;
    vec3 blurred = vec3(0.0);
    float total_weight = 0.0;
    
    float sigma = 3.0;
    float kernel_size = 5.0;
    
    for (float x = -kernel_size; x <= kernel_size; x++) {
        for (float y = -kernel_size; y <= kernel_size; y++) {
            vec2 offset = vec2(x, y) / u_resolution;
            vec3 sample = texture2D(u_texture, uv + offset).rgb;
            
            float weight = gaussian(length(vec2(x, y)), sigma);
            weight *= max(0.0, 1.0 - abs(luminance(sample) - luminance(color)));
            
            blurred += sample * weight;
            total_weight += weight;
        }
    }
    
    blurred /= total_weight;
    gl_FragColor = vec4(blurred, 1.0);
}