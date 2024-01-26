uniform float EnableComposite <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 1.0;
	ui_label = "Enable Composite Connection";
> = 0.0;

uniform float SignalResY <
	ui_label = "Signal Resolution Y";
> = 320.0;

uniform float SignalResI <
	ui_label = "Signal Resolution I";
> = 80.0;

uniform float SignalResQ <
	ui_label = "Signal Resolution Q";
> = 40.0;

uniform float EnableScanlines <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 1.0;
	ui_label = "Enable Scanlines";
> = 0.0;

uniform float ResolutioN <
	ui_label = "TV Vertical Resolution";
> = 240.0;

uniform float BlackLvl <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 0.3;
	ui_step = 0.01;
	ui_label = "Black Level";
> = 0.0;

uniform float Contrast <
	ui_type = "drag";
	ui_min = 0.3;
	ui_max = 2.0;
	ui_step = 0.01;
	ui_label = "Contrast";
> = 1.0;

#include "ReShade.fxh"

#define TexSize float2(Resolution_X,Resolution_Y)
#define IptSize float2(Resolution_X,Resolution_Y)
#define OptSize float4(BUFFER_SCREEN_SIZE,1.0/BUFFER_SCREEN_SIZE)
#define SrcSize float4(TexSize,1.0/TexSize)
#define RGB_to_YIQ float3x3(0.299,0.587,0.114,0.596,-0.274,-0.322,0.211,-0.523,0.312)
#define YIQ_to_RGB float3x3(1.000,0.956,0.621,1.000,-0.272,-0.647,1.000,-1.106,1.703)
#define PI 3.14159265
#define Soure(j) float2(texcoord.x,texcoord.y-(offset.y-(j))*SrcSize.w)
#define Guss(x) (exp(-(x)*(x)*0.5))/sqrt(2.0*PI)
#define d(x,b) (PI*b*min(abs(x)+0.5,1.0/b))
#define e(x,b) (PI*b*min(max(abs(x)-0.5,-1.0/b),1.0/b))
#define STU(x,b) (d(x,b)+sin(d(x,b))-e(x,b)-sin(e(x,b)))/(2.0*PI)
#define GETC tex2Dlod(SamplerZ,float4(float2(texcoord.x-(offset-(i))*SrcSize.z,texcoord.y),0.0,0.0)).rgb
#define C(j) tex2Dlod(Sampler0,float4(Soure(j),0.0,0.0)).xyz
#define VAL_composite float3((c.x*STU((offset-(i)),(SignalResY/IptSize.x))),(c.y*STU((offset-(i)),(SignalResI/IptSize.x))),(c.z*STU((offset-(i)),(SignalResQ/IptSize.x))))
#define VAL c*STU((offset-(i)),(SignalResY/IptSize.x))
#define PCS_composite(i) (offset-(i));c=GETC;tempColor+=VAL_composite;
#define PCS(i) (offset-(i));c=GETC;tempColor+=VAL;
#define UAL_scanlines(j) Scanline((offset.y-(j)),C(j))
#define UAL(j) C(j)*STU((offset.y-(j)),(ResolutioN/IptSize.y))

#ifndef Resolution_X
#define Resolution_X 320
#endif

#ifndef Resolution_Y
#define Resolution_Y 240
#endif

#define Sampler0 ReShade::BackBuffer

texture TextureZ{Width=Resolution_X;Height=Resolution_Y;Format=RGBA16F;};
sampler SamplerZ{Texture=TextureZ;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=LINEAR;MinFilter=LINEAR;MipFilter=LINEAR;};

float  Integral(float x)
{
	float a1=0.4361836;
	float a2=-0.1201676;
	float a3=0.9372980;
	float p=0.3326700;
	float t=1.0/(1.0+p*abs(x));
	return (0.5-Guss(x)*(t*(a1+t*(a2+a3*t))))*sign(x);
}

float3 Scanline(float x,float3 c)
{
	float temp=sqrt(2.0*PI)*(ResolutioN/IptSize.y);
	float rrr=0.5*(IptSize.y*OptSize.w);
	float x1=(x+rrr)*temp;
	float x2=(x-rrr)*temp;
	c.r=(c.r*(Integral(x1)-Integral(x2)));
	c.g=(c.g*(Integral(x1)-Integral(x2)));
	c.b=(c.b*(Integral(x1)-Integral(x2)));
	c*=(OptSize.y/IptSize.y);
	return c;
}

float4 BlurPS(float4 position:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float4 c=tex2D(Sampler0,texcoord);
	if(EnableComposite==1.0)
	c.rgb=mul(RGB_to_YIQ,c.rgb);
	return c;
}

float4 WavePS(float4 position:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float offset=frac((texcoord.x*SrcSize.x)-0.5);
	float3 tempColor=0.0;
	float3 c;
	float i;
	float range;
	if(EnableComposite==1.0)
	range=ceil(0.5+IptSize.x/min(min(SignalResY,SignalResI),SignalResQ));else
	range=ceil(0.5+IptSize.x/SignalResY);
	if(EnableComposite==1.0)
	{for(i=-range;i<range+2.0;i++)
	{PCS_composite(i)}}else
	{for(i=-range;i<range+2.0;i++)
	{PCS(i)}}
	if(EnableComposite==1.0)
	tempColor=clamp(mul(YIQ_to_RGB,tempColor),0.0,1.0);else
	tempColor=clamp(tempColor,0.0,1.0);
	return float4(tempColor,1.0);
}

float4 ScanPS(float4 position:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float2 offset=frac((texcoord*SrcSize)-0.5);
	float3 tempColor=0.0;
	float i;
	float range=ceil(0.5+IptSize.y/ResolutioN);
	if(EnableScanlines==1.0)
	{for(i=-range;i<range+2.0;i++)
	{tempColor+=UAL_scanlines(i);}}else
	{for(i=-range;i<range+2.0;i++)
	{tempColor+=UAL(i);}}
	tempColor-=BlackLvl;
	tempColor*=(Contrast/1.0-BlackLvl);
	return float4(tempColor,1.0);
}

technique GTUv50
{
	pass Blur
	{	
	VertexShader=PostProcessVS;
	PixelShader=BlurPS;
	RenderTarget=TextureZ;
	}
	pass Wave
	{
	VertexShader=PostProcessVS;
	PixelShader=WavePS;
	}
	pass Scan
	{
	VertexShader=PostProcessVS;
	PixelShader=ScanPS;
	}
}