varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;

uniform highp float alpha;
 
void main()
{
//    lowp vec3 luminace = vec3(1.0);
//    lowp vec3 origin_texel = texture2D(inputImageTexture, textureCoordinate).rgb;
//    lowp vec3 color = mix(origin_texel, luminace, alpha);
//    gl_FragColor = vec4(color, 1.0);
    
    gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
}
