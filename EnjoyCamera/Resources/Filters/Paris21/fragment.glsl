varying highp vec2 textureCoordinate;
 
uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture_1;

uniform highp float alpha;
 
void main()
{
    lowp vec3 color = texture2D(inputImageTexture, textureCoordinate).rgb;
	lowp vec4 texel = texture2D(inputImageTexture_1, textureCoordinate);
	lowp vec3 resultColor;
	
	if(color.r < 0.5)
	{
	    resultColor.r = color.r * texel.r * 2.0;
	}
	else
	{
	    resultColor.r = texel.a - (1.0 - color.r) * (texel.a - texel.r) * 2.0;
	}
	
	if(color.g < 0.5)
	{
	    resultColor.g = color.g * texel.g * 2.0;
	}
	else
	{
	    resultColor.g = texel.a - (1.0 - color.g) * (texel.a - texel.g) * 2.0;
	}
	
	if(color.b < 0.5)
	{
	    resultColor.b = color.b * texel.b * 2.0;
	}
	else
	{
	    resultColor.b = texel.a - (1.0 - color.b) * (texel.a - texel.b) * 2.0;
	}
	
	resultColor = color * (1.0 - texel.a) + resultColor;
	resultColor = resultColor * 0.935;
	
	gl_FragColor = vec4(mix(color, resultColor, alpha), 1.0);
}