uniform float sizexy <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 0.3;
	ui_step = 0.01;
	ui_label = "Halation Amplitude";
> = 0.1;

uniform float spread <
	ui_type = "drag";
	ui_min = 0.1;
	ui_max = 4.0;
	ui_step = 0.1;
	ui_label = "Halation Blur Size";
> = 1.0;

uniform float gammam <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 4.0;
	ui_step = 0.05;
	ui_label = "Gamma Output";
> = 2.2;

uniform float gammac <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 4.0;
	ui_step = 0.05;
	ui_label = "Gamma Input";
> = 2.4;

uniform float brightness <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 2.0;
	ui_step = 0.1;
	ui_label = "Brightness";
> = 1.0;

uniform float dmw <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.05;
	ui_label = "CRT Masks Strength";
> = 0.3;

uniform float wib <
	ui_type = "drag";
	ui_min = 0.1;
	ui_max = 0.5;
	ui_step = 0.05;
	ui_label = "Scanlines Strength";
> = 0.3;

uniform float gaussian_scanlines <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 1.0;
	ui_label = "Gaussian Scanlines";
> = 0.0;

uniform float cornerblur <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 6.0;
	ui_step = 0.05;
	ui_label = "Corner Blur";
> = 6.0;

uniform float cornersize <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.05;
	ui_label = "Corner Size";
> = 0.0;

uniform float curvature <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 1.0;
	ui_label = "Curvature Toggle";
> = 0.0;

uniform float crvradius <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 9.0;
	ui_step = 0.1;
	ui_label = "Curvature Radius";
> = 2.25;

uniform float vdistance <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 9.0;
	ui_step = 0.1;
	ui_label = "Curvature Length";
> = 2.25;

#include "ReShade.fxh"

#define TexSize float2(Resolution_X,Resolution_Y)
#define IptSize float2(Resolution_X,Resolution_Y)
#define OptSize float4(BUFFER_SCREEN_SIZE,1.0/BUFFER_SCREEN_SIZE)
#define SrcSize float4(TexSize,1.0/TexSize)
#define sinangle sin(0.0)
#define cosangle cos(0.0)
#define stretch mxscale()
#define aspect float2(1.0,0.75)
#define FIX(c) max(abs(c),1e-5)
#define PI 3.14159265
#define fmod_fact texcoord.x*TexSize.x*OptSize.x/IptSize.x
#define TEX0D(v) pow(tex2D(GEOM_S00,v).rgb,2.2)
#define TEX1D(v) pow(tex2D(GEOM_S01,v).rgb,2.2)
#define TEX2D(c) tex2D(ReShade::BackBuffer,(c))

#ifndef Resolution_X
#define Resolution_X 320
#endif

#ifndef Resolution_Y
#define Resolution_Y 240
#endif

#define GEOM_S00 ReShade::BackBuffer

texture GEOM_T01{Width=Resolution_X;Height=Resolution_Y;Format=RGBA16F;};
sampler GEOM_S01{Texture=GEOM_T01;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=LINEAR;MinFilter=LINEAR;MipFilter=LINEAR;};

texture GEOM_T02{Width=Resolution_X;Height=Resolution_Y;Format=RGBA16F;};
sampler GEOM_S02{Texture=GEOM_T02;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=LINEAR;MinFilter=LINEAR;MipFilter=LINEAR;};

uniform int framecount<source="framecount";>;

float intersect(float2 xy)
{
	float A=dot(xy,xy)+vdistance*vdistance;
	float B=2.0*(crvradius*(dot (xy,sinangle)-vdistance*cosangle*cosangle)-vdistance*vdistance);
	float C=vdistance*vdistance+2.0*crvradius*vdistance*cosangle*cosangle;
	return(-B-sqrt(B*B-4.0*A*C))/(2.0*A);
}

float2 bwtrans(float2 xy)
{
	float c=intersect(xy);
	float2 _pnt=c*xy;
	_pnt-=-crvradius*sinangle;
	_pnt/=crvradius;
	float2 tang=sinangle/cosangle;
	float2 poc=_pnt/cosangle;
	float A=dot(tang,tang)+1.0;
	float B=-2.0*dot(poc,tang);
	float C=dot(poc,poc)-1.0;
	float a=(-B+sqrt(B*B-4.0*A*C))/(2.0*A);
	float2 uv=(_pnt-a*sinangle)/cosangle;
	float r=FIX(crvradius*acos(a));
	return uv*r/sin(r/crvradius);
}

float2 fwtrans(float2 uv)
{
	float r=FIX(sqrt(dot(uv,uv)));
	uv*=sin(r/crvradius)/r;
	float x=1.0-cos(r/crvradius);
	float D=vdistance/crvradius+x*cosangle*cosangle+dot(uv,sinangle);
	return vdistance*(uv*cosangle-x*sinangle)/D;
}

float3 mxscale()
{
	float2 c=bwtrans(-crvradius*sinangle/(1.0+crvradius/vdistance*cosangle*cosangle));
	float2 a=0.5*aspect;
	float2 lo=float2(fwtrans(float2(-a.x,c.y)).x,fwtrans(float2(c.x,-a.y)).y)/aspect;
	float2 hi=float2(fwtrans(float2(+a.x,c.y)).x,fwtrans(float2(c.x,+a.y)).y)/aspect;
	return float3((hi+lo)*aspect*0.5,max(hi.x-lo.x,hi.y-lo.y));
}

float2 transform(float2 coord)
{
	coord=(coord-0.5)*aspect*stretch.z+stretch.xy;
	return(bwtrans(coord)/1.0/aspect+0.5);
}

float corner(float2 coord)
{
	coord*=SrcSize.xy/IptSize.xy;
	coord=(coord-0.5)*1.0+0.5;
	coord=min(coord,1.0-coord)*float2(1.0,OptSize.y/OptSize.x);
	float2 cdist=max(cornersize/10.0,max((1.0-smoothstep(100.0,600.0,cornerblur*100.0))*0.01,0.002));
	coord=(cdist-min(coord,cdist));
	float dist=sqrt(dot(coord,coord));
	return clamp((cdist.x-dist)*cornerblur*100.0,0.0,1.0);
}

float mod(float x,float y)
{
	return x-y* floor(x/y);
}

float4 scanlines(float distance,float4 color)
{
	if(gaussian_scanlines==1.0){
	float4 wid=0.3+0.1*pow(color,3.0);
	float4 weights=distance/wid;
	return 0.4*exp(-weights*weights)/wid;}else{
	float4 wid=2.0+2.0*pow(color,4.0);
	float4 weights=distance/wib;
	return 1.4*exp(-pow(weights*rsqrt(0.5*wid),wid))/(0.6+0.2*wid);}
}

float4 HGasPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float wid=spread*TexSize.x/(320.0*aspect.x);
	float one=1.0/TexSize.x;
	float4 co=exp(float4(1.0,4.0,9.0,16.0)*(-1.0/wid/wid));
	float3 sm=0.0;
	sm+=TEX0D(texcoord+float2(-4.0*one,0.0))*co.w;
	sm+=TEX0D(texcoord+float2(-3.0*one,0.0))*co.z;
	sm+=TEX0D(texcoord+float2(-2.0*one,0.0))*co.y;
	sm+=TEX0D(texcoord+float2(-1.0*one,0.0))*co.x;
	sm+=TEX0D(texcoord);
	sm+=TEX0D(texcoord+float2(+1.0*one,0.0))*co.x;
	sm+=TEX0D(texcoord+float2(+2.0*one,0.0))*co.y;
	sm+=TEX0D(texcoord+float2(+3.0*one,0.0))*co.z;
	sm+=TEX0D(texcoord+float2(+4.0*one,0.0))*co.w;
	float nrm=1.0/(1.0+2.0*(co.x+co.y+co.z+co.w));
	return float4(pow(sm*nrm,1.0/2.2),1.0);
}

float4 VGasPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float wid=spread*TexSize.y/(320.0*aspect.y);
	float one=1.0/TexSize.y;
	float4 co=exp(float4(1.0,4.0,9.0,16.0)*(-1.0/wid/wid));
	float3 sm=0.0;
	sm+=TEX1D(texcoord+float2(0.0,-4.0*one))*co.w;
	sm+=TEX1D(texcoord+float2(0.0,-3.0*one))*co.z;
	sm+=TEX1D(texcoord+float2(0.0,-2.0*one))*co.y;
	sm+=TEX1D(texcoord+float2(0.0,-1.0*one))*co.x;
	sm+=TEX1D(texcoord);
	sm+=TEX1D(texcoord+float2(0.0,+1.0*one))*co.x;
	sm+=TEX1D(texcoord+float2(0.0,+2.0*one))*co.y;
	sm+=TEX1D(texcoord+float2(0.0,+3.0*one))*co.z;
	sm+=TEX1D(texcoord+float2(0.0,+4.0*one))*co.w;
	float nrm=1.0/(1.0+2.0*(co.x+co.y+co.z+co.w));
	return float4(pow(sm*nrm,1.0/2.2),1.0);
}

float4 GeomPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 ilfac=float2(1.0,clamp(floor(IptSize.y/200.0),1.0,2.0));
	float2 xy=curvature?transform(texcoord):(texcoord-0.5)/1.0+0.5;
	float2 ilvec=float2(0.0,0.0>1.5?mod(framecount,2.0):0.0);
	float2 ratio_scale=(xy*TexSize-0.5+ilvec)/ilfac;
	float2 uv_ratio=frac(ratio_scale);
	float2 cone=ilfac/TexSize;
	float2 yx=xy;
	float cval=corner(xy);
	float clear=fwidth(ratio_scale.y);
	xy=(floor(ratio_scale)*ilfac+0.5-ilvec)/TexSize;
	float4 co=PI*float4(1.0+uv_ratio.x,uv_ratio.x,1.0-uv_ratio.x,2.0-uv_ratio.x);
	co =FIX(co);
	co =2.0*sin(co)*sin(co/2.0)/(co*co);
	co/=dot(co,1.0);
	float4 col0=clamp(TEX2D(xy+float2(-cone.x,cone.y))*co.x+TEX2D(xy+float2(0.0,cone.y))*co.y+TEX2D(xy+cone)*co.z+TEX2D(xy+float2(2.0*cone.x,cone.y))*co.w,0.0,1.0);
	float4 col1=clamp(TEX2D(xy+float2(-cone.x,0.0))*co.x+TEX2D(xy)*co.y+TEX2D(xy+float2(cone.x,0.0))*co.z+TEX2D(xy+float2(2.0*cone.x,0.0))*co.w,0.0,1.0);
	col0=pow(col0,gammac);
	col1=pow(col1,gammac);
	float4 weights0=scanlines(1.0-uv_ratio.y,col0);
	float4 weights1=scanlines(uv_ratio.y,col1);
	uv_ratio.y=uv_ratio.y+1.0/3.0*clear;
	weights0=(weights0+scanlines(abs(1.0-uv_ratio.y),col0))/3.0;
	weights1=(weights1+scanlines(abs(uv_ratio.y),col1))/3.0;
	uv_ratio.y=uv_ratio.y-2.0/3.0*clear;
	weights0=weights0+scanlines(abs(1.0-uv_ratio.y),col0)/3.0;
	weights1=weights1+scanlines(abs(uv_ratio.y),col1)/3.0;
	float3 mul_res=(col1*weights1+col0*weights0).rgb;
	float3 blur=pow(tex2D(GEOM_S02,yx).rgb,gammac);
	mul_res=lerp(mul_res,blur,sizexy);
	float3 maskweights=lerp(float3(1.0,1.0-dmw,1.0),float3(1.0-dmw,1.0,1.0-dmw),floor(mod(fmod_fact,2.0)));
	mul_res*=maskweights*brightness;
	mul_res=pow(mul_res,1.0/gammam);
	return float4(mul_res*cval,1.0);
}

technique CRT_Geom
{
	pass Gauss_X
	{
	VertexShader=PostProcessVS;
	PixelShader=HGasPS;
	RenderTarget=GEOM_T01;
	}
	pass Gauss_Y
	{
	VertexShader=PostProcessVS;
	PixelShader=VGasPS;
	RenderTarget=GEOM_T02;
	}
	pass GeomCRT
	{
	VertexShader=PostProcessVS;
	PixelShader=GeomPS;
	}
}