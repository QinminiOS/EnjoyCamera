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
    
	lowp vec3 texel = origin_texel;
    lowp vec3 edge = texture2D(inputImageTexture_1, textureCoordinate).rgb;
    texel = texel * edge;

    texel = vec3(texture2D(inputImageTexture_2, vec2(texel.r, 0.16667)).r, texture2D(inputImageTexture_2, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture_2, vec2(texel.b, 0.83333)).b);

    lowp vec3 luma = vec3(0.30, 0.59, 0.11);
    lowp vec3 gradSample = texture2D(inputImageTexture_3, vec2(dot(luma, texel), 0.5)).rgb;
    lowp vec3 final = vec3(texture2D(inputImageTexture_4, vec2(gradSample.r, texel.r)).r, texture2D(inputImageTexture_4, vec2(gradSample.g, texel.g)).g, texture2D(inputImageTexture_4, vec2(gradSample.b, texel.b)).b);

    lowp vec3 metal = texture2D(inputImageTexture_5, textureCoordinate).rgb;
    texel = vec3(texture2D(inputImageTexture_4, vec2(metal.r, texel.r)).r, texture2D(inputImageTexture_4, vec2(metal.g, texel.g)).g, texture2D(inputImageTexture_4, vec2(metal.b, texel.b)).b);

	gl_FragColor = vec4(mix(origin_texel, texel, alpha), 1.0);
}