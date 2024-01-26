uniform float DarkenScreen <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 2.0;
	ui_step = 0.05;
	ui_label = "Darken Screen";
> = 0.0;

#include "ReShade.fxh"

float4 NDSColorPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float4 screen=pow(tex2D(ReShade::BackBuffer,texcoord),2.2+DarkenScreen).rgba;
	float4 avglum=0.5;
	screen=lerp(screen,avglum,0.0);
	float4x4 colour=float4x4(0.815,0.215,-0.12,0.0,0.07,0.62,0.22,0.0,0.075,0.155,0.77,0.0,0.0,0.0,0.0,1.0);
	float4x4 adjust=float4x4(1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,1.0,1.0,1.0,1.0);
	colour=mul(colour,adjust);
	screen=saturate(screen*0.97);
	screen=mul(colour,screen);
	return pow(screen,1.0/2.2);
}

technique NDSColor
{
	pass
	{
	VertexShader=PostProcessVS;
	PixelShader=NDSColorPS;
	}
}