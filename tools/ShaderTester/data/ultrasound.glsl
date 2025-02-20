uniform sampler2D tex0;
uniform float time;
uniform vec2 resolution;

float noise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    
    float res = mix(
        mix(dot(sin(ip), vec2(12.9898,78.233)),
            dot(sin(ip + vec2(1.0, 0.0)), vec2(12.9898,78.233)), u.x),
        mix(dot(sin(ip + vec2(0.0, 1.0)), vec2(12.9898,78.233)),
            dot(sin(ip + vec2(1.0, 1.0)), vec2(12.9898,78.233)), u.x),
        u.y);
    return res * 0.5 + 0.5;
}

float shape(vec2 pos, float t) {
    float angle = atan(pos.y, pos.x);
    float radius = length(pos);
    float twist = sin(angle * 3.0 + t + radius * 2.0);
    return smoothstep(0.4, 0.41, twist + noise(pos * 2.0 + t));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    //vec2 uv = (fragCoord.xy - 0.5 * resolution.xy) / resolution.y;
    vec2 uv = fragCoord / resolution.xy;
    vec4 texCol = texture(tex0, uv);

    float shape1 = shape(uv * 2.0, time * 0.5);
    float shape2 = shape(uv * 3.0 + 0.2, time * 0.3);
    float shape3 = shape(uv * 1.5 - 0.1, time * 0.7);
    
    float finalShape = shape1 * 0.5 + shape2 * 0.3 + shape3 * 0.2;
    finalShape += noise(uv * 4.0 + time * 0.1) * 0.2;
    
    float scanline = sin(uv.y * 100.0 + time * 5.0) * 0.05;
    finalShape += scanline;
    
    float grain = noise(uv * 50.0) * 0.1;
    
    vec3 color = texCol.xxx / vec3(finalShape + grain);
    color = smoothstep(0.1, 0.9, color);
    
    fragColor = vec4(color, 1.0);
}

void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}