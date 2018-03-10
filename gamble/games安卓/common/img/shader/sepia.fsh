varying vec2 v_texCoord;
uniform float u_degree;
void main()
{
    vec4 texColor = texture2D(CC_Texture0, v_texCoord);
    float r = texColor.r * 0.393 + texColor.g * 0.769 + texColor.b * 0.189;
    float g = texColor.r * 0.349 + texColor.g * 0.686 + texColor.b * 0.168;
    float b = texColor.r * 0.272 + texColor.g * 0.534 + texColor.b * 0.131;
    gl_FragColor = mix(texColor, vec4(r, g, b, texColor.a), float(u_degree));
}