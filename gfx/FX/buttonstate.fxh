VertexStruct VS_INPUT
{
	float3 vPosition  : POSITION;
	float2 vTexCoord  : TEXCOORD0;
};

ConstantBuffer( 0, 0 )
{
	float4x4 WorldViewProjectionMatrix;
	float4 Color;
	float2 Offset;
	float2 NextOffset;
	float Time;
	float AnimationTime;
};
PixelShader =
{
	Code
	[[
		float3 ToLinear(float3 aGamma)
		{
			return pow(aGamma, vec3(2.2));
		}

		float4 ToLinear(float4 aGamma)
		{
			return float4(pow(aGamma.rgb, vec3(2.2)), aGamma.a);
		}
		float3 HuePost( float H )
	{
		float X = 1 - abs( ( mod( H, 2 ) ) - 1 );
		if ( H < 1.0f )			return float3( 1.0f,    X, 0.0f );
		else if ( H < 2.0f )	return float3(    X, 1.0f, 0.0f );
		else if ( H < 3.0f )	return float3( 0.0f, 1.0f,    X );
		else if ( H < 4.0f )	return float3( 0.0f,    X, 1.0f );
		else if ( H < 5.0f )	return float3(    X, 0.0f, 1.0f );
		else					return float3( 1.0f, 0.0f,    X );
	}

	float3 HSVtoRGBPost( in float3 aHSV )
	{
		if ( aHSV.y != 0.0f )
		{
			float C = aHSV.y * aHSV.z;
			return clamp( HuePost( aHSV.x ) * C + ( aHSV.z - C ), 0.0f, 1.0f );
		}
		return saturate( aHSV.zzz );
	}

	float3 RGBtoHSV( in float3 RGB )
	{
		float Cmax = max( RGB.r, max( RGB.g, RGB.b ) );
		float Cmin = min( RGB.r, min( RGB.g, RGB.b ) );
		float diff = Cmax - Cmin;

		float H = 0.0;
		float S = 0.0;
		if (diff != 0.0)
		{
			S = diff / Cmax;

			if (Cmax == RGB.r)
				H = (RGB.g - RGB.b) / diff + 6.0;
			else if (Cmax == RGB.g)
				H = (RGB.b - RGB.r) / diff + 2.0;
			else
				H = (RGB.r - RGB.g) / diff + 4.0;
		}

		return float3(H, S, Cmax);
	}


	float3 Hue(float H)
	{
	    float R = abs(H * 6 - 3) - 1;
	    float G = 2 - abs(H * 6 - 2);
	    float B = 2 - abs(H * 6 - 4);
	    return saturate(float3(R,G,B));
	}

	// used for manual input, converts to linear
	float3 HSVtoRGB(float H, float S, float V)
	{
		float3 hue = Hue(H);
		float3 val = (hue - vec3(1)) * S + vec3(1);
		val *= V;

	    return ToLinear( val );
	}

	float3 HSVtoRGB(float3 hsv)
	{
		return HSVtoRGB(hsv.r, hsv.g, hsv.b);
	}
		float4 desaturateRGBA( in float4 RGBA, float dF)
		{
			float3 hsv = RGBtoHSV(RGBA.rgb);
			hsv.g *= (1-dF);
			float3 outrgb = HSVtoRGB(hsv);
			float4 outColor = float4(outrgb.r, outrgb.g, outrgb.b, RGBA.a);
			return outColor;
		}
	]]
}