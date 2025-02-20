uniform sampler2D tex0;
uniform vec2 iResolution;

const float radius = 11.0;             // Radius of the blur
const float sigmaColor = 12.0;         // Variance for color weighting
const float sigmaSpace = 20.0;         // Variance for space weighting

// Gaussian function
float gaussian(float x, float sigma) {
    return exp(-0.5 * (x * x) / (sigma * sigma)) / (2.0 * 3.14159265 * sigma * sigma);
}

// Uniforms for texture data
uniform sampler2D currentFrame;    // Current noisy frame
uniform sampler2D previousFrame;   // Previous denoised frame
uniform sampler2D motionVector;    // Motion vector texture to track pixel movement
uniform float feedbackFactor;      // How much the previous frame contributes (between 0 and 1)
uniform vec2 resolution;           // Resolution of the screen

// Output color
out vec4 FragColor;

// Function to perform a simple 3x3 spatial filter (Gaussian-like)
vec3 spatialFilter(sampler2D tex, vec2 uv)
{
    vec2 texelSize = 1.0 / resolution;
    vec3 color = vec3(0.0);
    
    // Sample a 3x3 neighborhood for spatial denoising
    color += texture(tex, uv + vec2(-texelSize.x, -texelSize.y)).rgb * 0.0625;
    color += texture(tex, uv + vec2(0.0, -texelSize.y)).rgb * 0.125;
    color += texture(tex, uv + vec2(texelSize.x, -texelSize.y)).rgb * 0.0625;
    
    color += texture(tex, uv + vec2(-texelSize.x, 0.0)).rgb * 0.125;
    color += texture(tex, uv).rgb * 0.25;  // Center pixel
    color += texture(tex, uv + vec2(texelSize.x, 0.0)).rgb * 0.125;
    
    color += texture(tex, uv + vec2(-texelSize.x, texelSize.y)).rgb * 0.0625;
    color += texture(tex, uv + vec2(0.0, texelSize.y)).rgb * 0.125;
    color += texture(tex, uv + vec2(texelSize.x, texelSize.y)).rgb * 0.0625;
    
    return color;
}

void main()
{
    // Get the motion vector for the current pixel
    vec2 motion = texture(motionVector, TexCoord).xy;
    
    // Reproject the previous frame to the current pixel's position using motion vector
    vec2 reprojectedUV = TexCoord + motion;
    
    // Sample the previous denoised frame at the reprojected position
    vec3 previousColor = texture(previousFrame, reprojectedUV).rgb;
    
    // Sample the current noisy frame at the current position
    vec3 currentColor = texture(currentFrame, TexCoord).rgb;
    
    // Apply spatial filtering on the current frame to reduce local noise
    vec3 filteredCurrentColor = spatialFilter(currentFrame, TexCoord);
    
    // Blend between the spatially filtered current frame and the temporally accumulated previous frame
    vec3 finalColor = mix(filteredCurrentColor, previousColor, feedbackFactor);
    
    // Output the final color
    FragColor = vec4(finalColor, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = vec2(uv.x, abs(1.0 - uv.y));

    vec2 texelSize = 1.0 / iResolution;  // Size of one texel
    vec3 centerColor = texture(tex0, uv).rgb;
    
    float sumWeights = 0.0;
    vec3 finalColor = vec3(0.0);
    
    // Loop through neighboring pixels in a radius
    for (int x = -int(radius); x <= int(radius); x++) {
        for (int y = -int(radius); y <= int(radius); y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            vec3 sampleColor = texture(tex0, uv + offset).rgb;
            
            // Calculate spatial weight (based on distance)
            float spaceWeight = gaussian(length(vec2(x, y)), sigmaSpace);
            
            // Calculate color weight (based on color difference)
            float colorWeight = gaussian(length(sampleColor - centerColor), sigmaColor);
            
            // Combine the weights
            float weight = spaceWeight * colorWeight;
            
            // Accumulate weighted color
            finalColor += sampleColor * weight;
            sumWeights += weight;
        }
    }
    
    // Normalize the final color by the sum of the weights
    finalColor /= sumWeights;
    
    // Output the denoised color
    fragColor = vec4(finalColor, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
