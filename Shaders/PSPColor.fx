uniform float DarkenScreen <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 2.0;
	ui_step = 0.05;
	ui_label = "Darken Screen";
> = 0.0;

#include "ReShade.fxh"

float4 PSPColorPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float4 screen=pow(tex2D(ReShade::BackBuffer,texcoord),2.2+DarkenScreen).rgba;
	float4 avglum=0.5;
	screen=lerp(screen,avglum,0.0);
	float4x4 colour=float4x4(0.98,0.25,-0.18,0.0,0.04,0.795,0.165,0.0,0.01,0.01,0.98,0.0,0.0,0.0,0.0,1.0);
	float4x4 adjust=float4x4(1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,1.0,1.0,1.0,1.0);
	colour=mul(colour,adjust);
	screen=saturate(screen*1.0);
	screen=mul(colour,screen);
	return pow(screen,1.0/2.2);
}

technique PSPColor
{
	pass
	{
	VertexShader=PostProcessVS;
	PixelShader=PSPColorPS;
	}
}