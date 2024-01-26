uniform float DRK <
	ui_label = "Fix LUT Dark Range";
> = 5.0;

uniform float BRT <
	ui_label = "Fix LUT Brightness";
> = 1.0;

#include "ReShade.fxh"

texture TextureTV<source="LUT-Guest.png";>{Width=1024;Height=32;};
sampler SamplerTV{Texture=TextureTV;};

float3 fix_lut(float3 lut,float3 ref)
{
	float r=length(ref);
	float l=length(lut);
	float m=max(max(ref.r,ref.g),ref.b);
	ref=normalize(lut+0.0000001)* lerp(r,l,pow(m,1.25));
	return lerp(lut,ref,BRT);
}

float3 TrinitronPS(float4 position:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float4 image=tex2D(ReShade::BackBuffer,texcoord.xy);
	image.rgb=min(image.rgb,1.0);
	float3 color=image.rgb;
	float lutlow=DRK/255.0;
	float inverse=1.0/32.0;
	float3 table=image.rgb+lutlow*(1.0-pow(image.rgb,0.333.xxx));table.rg=table.rg*(1.0-inverse)+0.5*inverse;
	float blue=table.b* (1.0-0.5*inverse);
	float tile=ceil(blue*(32.0-1.0));
	float mile=max(tile-1.0,0.0);
	float flat=frac(blue*(32.0-1.0));if(flat==0.0)flat=1.0;
	float2 coord1=float2(mile+table.r,table.g)*float2(inverse,1.0);
	float2 coord2=float2(tile+table.r,table.g)*float2(inverse,1.0);
	float4 color1=tex2D(SamplerTV,coord1);
	float4 color2=tex2D(SamplerTV,coord2);
	float4 res=lerp(color1,color2,flat);res.rgb=fix_lut(res.rgb,image.rgb);
	color=lerp(image.rgb,res.rgb,min(1.0,1.0));
	return color;
}

technique LUT_Guest
{
	pass
	{
	VertexShader=PostProcessVS;
	PixelShader=TrinitronPS;
	}
}