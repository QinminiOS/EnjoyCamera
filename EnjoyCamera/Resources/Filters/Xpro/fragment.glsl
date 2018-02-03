varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;
uniform sampler2D inputImageTexture_2;

uniform highp float alpha;
 
void main()
{
    lowp vec3 origin_texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
	lowp vec3 texel = origin_texel;
	lowp vec2 tc = (2.0 * textureCoordinate) - 1.0;
	lowp float d = dot(tc, tc);
	texel = vec3(texture2D(inputImageTexture_2, vec2(d, texel.r)).r, texture2D(inputImageTexture_2, vec2(d, texel.g)).g, texture2D(inputImageTexture_2, vec2(d, texel.b)).b);
	
	texel = vec3(texture2D(inputImageTexture_1, vec2(texel.r, 0.16667)).r, texture2D(inputImageTexture_1, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_1, vec2(texel.b, 0.83333)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}