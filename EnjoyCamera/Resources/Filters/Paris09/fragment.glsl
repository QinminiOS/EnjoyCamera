varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;

uniform highp float alpha;

lowp vec3 texel;
lowp vec3 color;
highp float blueColor;
highp vec2 quad1;
highp vec2 quad2;
highp vec2 texPos1;
highp vec2 texPos2;
lowp vec4 newColor1;
lowp vec4 newColor2;
void main()
{
    texel=texture2D(inputImageTexture, textureCoordinate).rgb;
    
	blueColor = texel.b * 15.0;
    quad1.y = floor(floor(blueColor) / 4.0);
    quad1.x = floor(blueColor) - (quad1.y * 4.0);
    quad2.y = floor(ceil(blueColor) / 4.0);
    quad2.x = ceil(blueColor) - (quad2.y * 4.0);
    texPos1.x = (quad1.x * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * texel.r);
    texPos1.y = (quad1.y * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * texel.g);
    texPos2.x = (quad2.x * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * texel.r);
    texPos2.y = (quad2.y * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * texel.g);
    newColor1 = texture2D(inputImageTexture_1, texPos1);
    newColor2 = texture2D(inputImageTexture_1, texPos2);
    color = mix(newColor1.rgb, newColor2.rgb, fract(blueColor));
    texel = mix(texel, color, alpha);
    gl_FragColor = vec4(texel.rgb, 1.0);
}