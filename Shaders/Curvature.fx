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
> = 2.0;

uniform float vdistance <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 9.0;
	ui_step = 0.1;
	ui_label = "Curvature Length";
> = 2.0;

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

uniform float gammac <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 4.0;
	ui_step = 0.05;
	ui_label = "Gamma Input";
> = 2.4;

uniform float gammam <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 4.0;
	ui_step = 0.05;
	ui_label = "Gamma Output";
> = 2.4;

#include "ReShade.fxh"

#define TexSize float2(BUFFER_WIDTH,BUFFER_HEIGHT)
#define IptSize float2(BUFFER_WIDTH,BUFFER_HEIGHT)
#define OptSize float4(BUFFER_SCREEN_SIZE,1.0/BUFFER_SCREEN_SIZE)
#define SrcSize float4(TexSize,1.0/TexSize)
#define sinangle sin(0.0)
#define cosangle cos(0.0)
#define stretch mxscale()
#define aspect float2(1.0,0.75)
#define FIX(c) max(abs(c),1e-5)
#define TEX2D(c) tex2D(ReShade::BackBuffer,(c))

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

float2 warper(float2 coord)
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

float3 CurvePS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 xy=curvature?warper(texcoord):texcoord;
	float4 tint=TEX2D(xy);
	tint=pow(tint,gammac);
	float3 colorful=(tint).rgb;
	colorful=pow(colorful,1.0/gammam);
	return colorful*corner(xy);
}

technique Curvature
{
	pass
	{
	VertexShader=PostProcessVS;
	PixelShader=CurvePS;
	}
}