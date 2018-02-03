varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;

uniform highp float alpha;
 
void main()
{
    lowp vec3 origin_texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
	lowp vec3 texel = vec3(texture2D(inputImageTexture_1, vec2(origin_texel.r, 0.1667)).r, texture2D(inputImageTexture_1, vec2(origin_texel.g, 0.5)).g, texture2D(inputImageTexture_1, vec2(origin_texel.b, 0.8333)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}
