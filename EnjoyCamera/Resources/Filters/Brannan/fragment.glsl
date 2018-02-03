varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;
uniform sampler2D inputImageTexture_2;
uniform sampler2D inputImageTexture_3;
uniform sampler2D inputImageTexture_4;
uniform sampler2D inputImageTexture_5;

uniform highp float alpha;
 
void main()
{
    lowp vec3 origin_texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
	lowp mat3 saturateMatrix = mat3(1.10515, -0.04485, -0.04600, -0.08805, 1.06195, -0.08920, -0.01710, -0.01710, 1.13290);
	lowp vec3 luma = vec3(0.3, 0.59, 0.11);
	lowp vec3 texel = origin_texel;
	texel = vec3(texture2D(inputImageTexture_1, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_1, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_1, vec2(texel.b, 0.5)).b);
	
	texel = saturateMatrix * texel;
	
	lowp vec2 tc = (2.0 * textureCoordinate) - 1.0;
	lowp float d = dot(tc, tc);
	lowp vec3 sampled = vec3(texture2D(inputImageTexture_2, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_2, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_2, vec2(texel.b, 0.5)).b);
	lowp float value = smoothstep(0.0, 1.0, d);
	texel = mix(sampled, texel, value);
	
	texel = vec3(texture2D(inputImageTexture_3, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_3, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_3, vec2(texel.b, 0.5)).b);
	texel = mix(texture2D(inputImageTexture_4, vec2(dot(texel, luma), 0.5)).rgb, texel, 0.5);
	
	texel = vec3(texture2D(inputImageTexture_5, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_5, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_5, vec2(texel.b, 0.5)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}