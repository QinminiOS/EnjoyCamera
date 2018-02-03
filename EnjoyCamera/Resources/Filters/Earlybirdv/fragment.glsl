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
    
	lowp mat3 saturateMatrix = mat3(1.21030, -0.08970, -0.09100, -0.17610, 1.12390, -0.17740, -0.03420, -0.03420, 1.26580);
	lowp vec3 rgbPrime = vec3(0.25098, 0.14641, 0.0);
	lowp vec3 desaturate = vec3(0.3, 0.59, 0.11);
	lowp vec3 texel = origin_texel;
	texel = vec3(texture2D(inputImageTexture_1, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_1, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_1, vec2(texel.b, 0.5)).b);
	
	lowp float desaturatedColor = dot(desaturate, texel);
	lowp vec3 result = vec3(texture2D(inputImageTexture_2, vec2(desaturatedColor, 0.5)).r, texture2D(inputImageTexture_2, vec2(desaturatedColor, 0.5)).g, texture2D(inputImageTexture_2, vec2(desaturatedColor, 0.5)).b);
	texel = saturateMatrix * mix(texel, result, 0.5);
	
	lowp vec2 tc = (2.0*textureCoordinate) - 1.0;
	lowp float d = dot(tc, tc);
	lowp vec3 sampled = vec3(texture2D(inputImageTexture_3, vec2(d, texel.r)).r, texture2D(inputImageTexture_3, vec2(d, texel.g)).g, texture2D(inputImageTexture_3, vec2(d, texel.b)).b);
	lowp float value = smoothstep(0.0, 1.25, pow(d, 1.35)/1.65);
	texel = mix(texel, sampled, value);
	
	texel = vec3(texture2D(inputImageTexture_4, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_4, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_4, vec2(texel.b, 0.5)).b);
	texel = mix(texel, sampled, value);
	
	texel = vec3(texture2D(inputImageTexture_5, vec2(texel.r, 0.5)).r, texture2D(inputImageTexture_5, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_5, vec2(texel.b, 0.5)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}