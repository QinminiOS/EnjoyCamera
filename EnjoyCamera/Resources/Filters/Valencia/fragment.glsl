varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;
uniform sampler2D inputImageTexture_2;

uniform highp float alpha;
 
void main()
{
    lowp vec3 origin_texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
	lowp mat3 saturateMatrix = mat3(1.14020, -0.05980, -0.06100, -0.11740, 1.08260, -0.11860, -0.02280, -0.02280, 1.17720);
	lowp vec3 luma = vec3(0.3, 0.59, 0.11);
	lowp vec3 texel = origin_texel;
	texel = vec3(texture2D(inputImageTexture_1, vec2(texel.r, 0.16667)).r, texture2D(inputImageTexture_1, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_1, vec2(texel.b, 0.83333)).b);
	
	texel = saturateMatrix * texel;
	lowp float lumaValue = dot(luma, texel);
	texel = vec3(texture2D(inputImageTexture_2, vec2(lumaValue, texel.r)).r, texture2D(inputImageTexture_2, vec2(lumaValue, texel.g)).g, texture2D(inputImageTexture_2, vec2(lumaValue, texel.b)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}