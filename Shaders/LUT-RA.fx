#include "ReShade.fxh"

texture TextureRA<source="LUT-RA.png";>{Width=1024;Height=32;};
sampler SamplerRA{Texture=TextureRA;};

float4 mix(float4 a,float4 b,float c)
{
	return (a.z<1.0)?lerp(a,b,c):a;
}

float4 TrinitronPS(float4 position:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float2 LUTSize=tex2Dsize(SamplerRA,0);
	float4 imgC=tex2D(ReShade::BackBuffer,texcoord.xy);
	float red_a=(imgC.r*(LUTSize.y-1.0)+0.4999)/(LUTSize.y*LUTSize.y);
	float grn_a=(imgC.g*(LUTSize.y-1.0)+0.4999)/ LUTSize.y;
	float blu_a=(floor(imgC.b*(LUTSize.y-1.0))/LUTSize.y)+red_a;
	float blu_b=( ceil(imgC.b*(LUTSize.y-1.0))/LUTSize.y)+red_a;
	float mixer=clamp(max((imgC.b-blu_a)/(blu_b-blu_a),0.0),0.0,32.0);
	float4 color1=tex2D(SamplerRA,float2(blu_a,grn_a));
	float4 color2=tex2D(SamplerRA,float2(blu_b,grn_a));
	return mix(color1,color2,mixer);
}

technique LUT_RA
{
	pass
	{
	VertexShader=PostProcessVS;
	PixelShader=TrinitronPS;
	}
}