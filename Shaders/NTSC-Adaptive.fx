uniform float cust_artifacting <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 5.0;
	ui_step = 0.1;
	ui_label = "NTSC Custom Artifacting Value";
> = 1.0;

uniform float cust_fringing <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 5.0;
	ui_step = 0.1;
	ui_label = "NTSC Custom Fringing Value";
> = 1.0;

uniform float ntsc_fields <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 3.0;
	ui_step = 1.0;
	ui_label = "NTSC Merge Fields: Auto | No | Yes";
> = 1.0;

uniform float ntsc_phase <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 4.0;
	ui_step = 1.0;
	ui_label = "NTSC Phase: Auto | 2 Phase | 3 Phase | Mixed";
> = 1.0;

uniform float ntsc_scale <
	ui_type = "drag";
	ui_min = 0.2;
	ui_max = 2.5;
	ui_step = 0.025;
	ui_label = "NTSC Resolution Scaling";
> = 1.0;

uniform float ntsc_taps <
	ui_type = "drag";
	ui_min = 6.0;
	ui_max = 32.0;
	ui_step = 1.0;
	ui_label = "NTSC # of Taps (Filter Width)";
> = 32.0;

uniform float ntsc_cscale1 <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 4.00;
	ui_step = 0.05;
	ui_label = "NTSC Chroma Scaling/Bleeding (2 Phase)";
> = 1.0;

uniform float ntsc_cscale2 <
	ui_type = "drag";
	ui_min = 0.2;
	ui_max = 2.25;
	ui_step = 0.05;
	ui_label = "NTSC Chroma Scaling/Bleeding (3 Phase)";
> = 1.0;

uniform float ntsc_sat <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 2.0;
	ui_step = 0.01;
	ui_label = "NTSC Color Saturation";
> = 1.0;

uniform float ntsc_brt <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.5;
	ui_step = 0.01;
	ui_label = "NTSC Brightness";
> = 1.0;

uniform float ntsc_gamma <
	ui_type = "drag";
	ui_min = 0.25;
	ui_max = 2.5;
	ui_step = 0.025;
	ui_label = "NTSC Filtering Gamma Correction";
> = 1.0;

uniform float ntsc_rainbow <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 3.0;
	ui_step = 1.0;
	ui_label = "NTSC Coloring/Rainbow Effect (2 Phase)";
> = 0.0;

uniform float ntsc_ring <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.1;
	ui_label = "NTSC Anti-Ringing";
> = 0.5;

uniform float ntsc_shrp <
	ui_type = "drag";
	ui_min = -10.0;
	ui_max = 10.0;
	ui_step = 0.5;
	ui_label = "NTSC Sharpness (Adaptive)";
> = 0.0;

uniform float ntsc_shpe <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 1.0;
	ui_step = 0.025;
	ui_label = "NTSC Sharpness Shape";
> = 0.8;

uniform float ntsc_charp1 <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 10.0;
	ui_step = 0.5;
	ui_label = "NTSC Preserve 'Edge' Colors (2 Phase)";
> = 0.0;

uniform float ntsc_charp2 <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 10.0;
	ui_step = 0.5;
	ui_label = "NTSC Preserve 'Edge' Colors (3 Phase)";
> = 0.0;

uniform float CSHARPEN <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 5.0;
	ui_step = 0.1;
	ui_label = "FSharpen - Sharpen Strength";
> = 0.0;

uniform float CCONTR <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 0.25;
	ui_step = 0.01;
	ui_label = "FSharpen - Sharpen (+ Deblur) Contrast";
> = 0.05;

uniform float CDETAILS <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.05;
	ui_label = "FSharpen - Sharpen Details";
> = 1.0;

uniform float DEBLUR <
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 7.0;
	ui_step = 0.25;
	ui_label = "FSharpen - Deblur Strength";
> = 1.0;

uniform float DREDGE <
	ui_type = "drag";
	ui_min = 0.7;
	ui_max = 1.0;
	ui_step = 0.01;
	ui_label = "FSharpen - Deblur Edges Falloff";
> = 0.9;

uniform float DSHARP <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 4.0;
	ui_step = 0.2;
	ui_label = "FSharpen - Deblur Extra Sharpen";
> = 0.0;

#include "ReShade.fxh"

#define TexSize float2(Resolution_X,Resolution_Y)
#define OrgSize float4(TexSize,1.0/TexSize)
#define pii 3.14159265
#define texCD(c,d) tex2Dlod(c,float4(d,0,0))
#define mix_m float3x3(BRIGHTNESS,ARTIFACT,ARTIFACT,FRINGING,2.0*SATURATION,0.0,FRINGING,0.0,2.0*SATURATION)
#define rgb_m float3x3(0.299,0.587,0.114,0.596,-0.274,-0.322,0.211,-0.523,0.312)
#define yiq_m float3x3(1.000,0.956,0.621,1.000,-0.272,-0.647,1.000,-1.106,1.703)
#define fetch_offset1(dx)  texCD(PAAL_S02,tex_c+dx).xyz+texCD(PAAL_S02,tex_c-dx).xyz
#define fetch_offset2(dx) float3(texCD(PAAL_S02,tex_c+dx.xz).x+texCD(PAAL_S02,tex_c-dx.xz).x,texCD(PAAL_S02,tex_c+dx.yz).yz+texCD(PAAL_S02,tex_c-dx.yz).yz)

#ifndef Resolution_X
#define Resolution_X 320
#endif

#ifndef Resolution_Y
#define Resolution_Y 240
#endif

#define PAAL_S00 ReShade::BackBuffer

texture PAAL_T01{Width=1.0*Resolution_X;Height=Resolution_Y ;Format=RGBA16F;};
sampler PAAL_S01{Texture=PAAL_T01;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=POINT ;MinFilter=POINT ;MipFilter=POINT ;};

texture PAAL_T02{Width=4.0*Resolution_X;Height=Resolution_Y ;Format=RGBA16F;};
sampler PAAL_S02{Texture=PAAL_T02;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=LINEAR;MinFilter=LINEAR;MipFilter=LINEAR;};

texture PAAL_T03{Width=2.0*Resolution_X;Height=Resolution_Y ;Format=RGBA16F;};
sampler PAAL_S03{Texture=PAAL_T03;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=POINT ;MinFilter=POINT ;MipFilter=POINT ;};

texture PAAL_T04{Width=2.0*Resolution_X;Height=Resolution_Y ;Format=RGBA16F;};
sampler PAAL_S04{Texture=PAAL_T04;AddressU=BORDER;AddressV=BORDER;AddressW=BORDER;MagFilter=POINT ;MinFilter=POINT ;MipFilter=POINT ;};

uniform int framecount<source="framecount";>;

float mod(float x,float y)
{
	return x-y* floor(x/y);
}

float3 rgb2yiq(float3 r)
{
	return mul(rgb_m, r);
}

float3 yiq2rgb(float3 y)
{
	return mul(yiq_m, y);
}

float get_luma(float3 c)
{
	return dot(c,float3(0.299,0.587,0.114));
}

float swoothstep(float e0,float e1,float x)
{
	return clamp((x-e0)/(e1-e0),0.0,1.0);
}

float4 StockPassPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	return texCD(PAAL_S00,texcoord);
}

float4 Signal_1_PS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float pix_res= min(ntsc_scale,1.0);
	float phase= (ntsc_phase<1.5)?((OrgSize.x>300.0)? 2.0:3.0):((ntsc_phase>2.5)?3.0:2.0);
	if(ntsc_phase==4.0)phase=3.0;
	float res=ntsc_scale;
	float CHROMA_MOD_FREQ=(phase<2.5)?(4.0*pii/15.0):(pii/3.0);
	float ARTIFACT=cust_artifacting;
	float FRINGING=cust_fringing;
	float BRIGHTNESS=ntsc_brt;
	float SATURATION=ntsc_sat;
	float MERGE=0.0;
	if(ntsc_fields== 1.0&&phase==3.0) MERGE=1.0;else
	if(ntsc_fields== 2.0) MERGE=0.0;else
	if(ntsc_fields== 3.0) MERGE=1.0;
	float2 pix_no=texcoord*OrgSize.xy*pix_res* float2(4.0,1.0);
	float3 col0=texCD(PAAL_S01, texcoord).rgb;
	float3 yiq1=rgb2yiq(col0);
	yiq1.x=pow(yiq1.x,ntsc_gamma); float lum=yiq1.x;
	float2 dx=float2(OrgSize.z,0.0);
	float c1=get_luma(texCD(PAAL_S01,texcoord-dx).rgb);
	float c2=get_luma(texCD(PAAL_S01,texcoord+dx).rgb);
	if(ntsc_phase==4.0)
	{
	float miix=min(5.0*abs(c1-c2),1.0);
	c1=pow(c1,ntsc_gamma);
	c2=pow(c2,ntsc_gamma);
	yiq1.x=lerp(min(0.5*(yiq1.x+max(c1,c2)),max(yiq1.x,min(c1,c2))),yiq1.x,miix);
	}
	float3 yiq2=yiq1;
	float3 yiqs=yiq1;
	float3 yiqz=yiq1;
	float3 temp=yiq1;
	float mit=ntsc_taps;if(ntsc_charp1>0.25&&phase==2.0)mit=clamp(mit,8.0,min(ntsc_taps,14.0));
	mit=swoothstep(16.0,8.0,mit)*0.325;
	if(MERGE>0.5)
	{
	float chroma_phase2=(phase<2.5)?pii*(mod(pix_no.y,2.0)+mod(float(framecount)+1,2.)):0.6667*pii*(mod(pix_no.y,3.0)+mod(float(framecount)+1,2.));
	float mod_phase2=chroma_phase2+pix_no.x*CHROMA_MOD_FREQ;
	float i_mod2=cos( mod_phase2 );
	float q_mod2=sin( mod_phase2 );
	yiq2.yz*=float2(i_mod2,q_mod2);
	yiq2=mul(mix_m,yiq2);
	yiq2.yz*=float2(i_mod2,q_mod2);
	yiq2.yz =lerp(yiq2.yz,temp.yz,mit);
	if(res>1.025)
	{
	mod_phase2=chroma_phase2 +res *pix_no.x*CHROMA_MOD_FREQ;
	i_mod2=cos(mod_phase2);
	q_mod2=sin(mod_phase2);
	yiqs.yz*=float2(i_mod2,q_mod2);
	yiq2.x=dot(yiqs,mix_m[0]);
	}
	}
	float chroma_phase1=(phase<2.5)?pii*(mod(pix_no.y,2.0)+mod(float(framecount)  ,2.)):0.6667*pii*(mod(pix_no.y,3.0)+mod(float(framecount)  ,2.));
	float mod_phase1=chroma_phase1+pix_no.x*CHROMA_MOD_FREQ;
	float i_mod1=cos( mod_phase1 );
	float q_mod1=sin( mod_phase1 );
	yiq1.yz*=float2(i_mod1,q_mod1);
	yiq1=mul(mix_m,yiq1);
	yiq1.yz*=float2(i_mod1,q_mod1);
	yiq1.yz =lerp(yiq1.yz,temp.yz,mit);
	if(res>1.025)
	{
	mod_phase1=chroma_phase1 +res *pix_no.x*CHROMA_MOD_FREQ;
	i_mod1=cos(mod_phase1);
	q_mod1=sin(mod_phase1);
	yiqz.yz*=float2(i_mod1,q_mod1);
	yiq1.x=dot(yiqz,mix_m[0]);
	}
	if(ntsc_phase==4.0){yiq1.x=lum;yiq2.x=lum;}
	if(MERGE>0.5){if(ntsc_rainbow<0.5||phase>2.5)yiq1=0.5*(yiq1+yiq2); else yiq1.x=0.5*(yiq1.x+yiq2.x);}
	return float4(yiq1,lum);
}

float4 Signal_2_PS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float chroma_filter_2_phase[33]={
    0.001384762, 0.001678312, 0.002021715, 0.002420562, 0.002880460, 0.003406879, 0.004004985, 0.004679445, 0.005434218, 0.006272332, 0.007195654,
    0.008204665, 0.009298238, 0.010473450, 0.011725413, 0.013047155, 0.014429548, 0.015861306, 0.017329037, 0.018817382, 0.020309220, 0.021785952,
    0.023227857, 0.024614500, 0.025925203, 0.027139546, 0.028237893, 0.029201910, 0.030015081, 0.030663170, 0.031134640, 0.031420995, 0.031517031};
	float chroma_filter_3_phase[25]={
   -0.000118847,-0.000271306,-0.000502642,-0.000930833,-0.001451013,
   -0.002064744,-0.002700432,-0.003241276,-0.003524948,-0.003350284,
   -0.002491729,-0.000721149, 0.002164659, 0.006313635, 0.011789103,
    0.018545660, 0.026414396, 0.035100710, 0.044196567, 0.053207202,
    0.061590275, 0.068803602, 0.074356193, 0.077856564, 0.079052396};
	float luma_filter_2_phase[33]={
   -0.000174844,-0.000205844,-0.000149453,-0.000051693, 0.000000000,-0.000066171,-0.000245058,-0.000432928,-0.000472644,-0.000252236, 0.000198929,
    0.000687058, 0.000944112, 0.000803467, 0.000363199, 0.000013422, 0.000253402, 0.001339461, 0.002932972, 0.003983485, 0.003026683,-0.001102056,
   -0.008373026,-0.016897700,-0.022914480,-0.021642347,-0.028863273, 0.027271957, 0.054921920, 0.098342579, 0.139044281, 0.168055832, 0.178571429};
	float luma_filter_3_phase[25]={
   -0.000012020,-0.000022146,-0.000013155,-0.000012020,-0.000049979,
   -0.000113940,-0.000122150,-0.000005612, 0.000170516, 0.000237199,
    0.000169640, 0.000285688, 0.000984574, 0.002018683, 0.002002275,
   -0.005909882,-0.012049081,-0.018222860,-0.022606931, 0.002460860,
    0.035868225, 0.084016453, 0.135563500, 0.175261268, 0.220176552};
	float luma_filter_4_phase[25]={
   -0.000472644,-0.000252236, 0.000198929, 0.000687058, 0.000944112,
    0.000803467, 0.000363199, 0.000013422, 0.000253402, 0.001339461,
    0.002932972, 0.003983485, 0.003026683,-0.001102056,-0.008373026,
   -0.016897700,-0.022914480,-0.021642347,-0.028863273, 0.027271957,
    0.054921920, 0.098342579, 0.139044281, 0.168055832, 0.178571429};
	const int TAPS_2_phase=32;
	const int TAPS_3_phase=24;
	float res=ntsc_scale;
	float3 signal=0.0;
	float2 one=0.25*OrgSize.zz/res;
	float2 tex_c=texcoord+float2(0.5*OrgSize.z/4.0,0.0);
	float phase= ( ntsc_phase<1.5)?((OrgSize.x>300.0)?2.0:3.0):((ntsc_phase>2.5)?3.0:2.0);
	if(ntsc_phase==4.0){phase=3.0;luma_filter_3_phase=luma_filter_4_phase;}
	float3 wsum =0.0.xxx;
	float3 sums=wsum;
	float3 tmps=wsum;
	float offset=0.0;int i=0;
	float j =0.0;
	if(phase<2.5)
	{
	float loop=max(ntsc_taps,8.0);
	if(ntsc_charp1>0.25)loop=min(loop,14.0);
	float loob=loop+1.0;
	float taps=0.0;
	float ssub=loop-loop/ntsc_cscale1;
	float mit=1.0+0.0375*pow(swoothstep(16.0,8.0,loop),0.5);
	float2 dx=float2(one.x*mit,0.0);
	float2 xd=dx; int loopstart=int(TAPS_2_phase-loop);
	for(i=loopstart;i<32;i++)
	{
	offset=float(i-loopstart);
	j=offset+1.0;xd= (offset-loop)*dx;
	sums=fetch_offset1(xd);
	taps=max(j-ssub,0.0);
	tmps=float3(luma_filter_2_phase[i], taps.xx );
	wsum=wsum+tmps; signal+=sums*tmps;
	}
	taps=loob-ssub;
	tmps=float3(luma_filter_2_phase[TAPS_2_phase], taps.xx);
	wsum=wsum+wsum+tmps;
	signal+=texCD(PAAL_S02,tex_c).xyz*tmps;
	signal =signal/wsum;
	}else
	{
	float loop=min(ntsc_taps,TAPS_3_phase); one.y=one.y/ntsc_cscale2;
	float mit=1.0;
	if(ntsc_phase==4.0){loop=max(loop,8.0); mit=1.0+0.0375*pow(swoothstep(16.0,8.0,loop),0.5);}
	float3 dx=float3(one.x,one.y,0.0);
	float3 xd=dx; int loopstart=int(TAPS_3_phase-loop);
	dx.x*=mit;
	for(i=loopstart;i<24;i++)
	{
	offset=float(i-loopstart);
	j=offset+1.0;xd.xy=(offset-loop)*dx.xy;
	sums=fetch_offset2(xd);
	tmps=float3(luma_filter_3_phase[i], chroma_filter_3_phase[i].xx);
	wsum=wsum+tmps; signal+=sums*tmps;
	}
	tmps=float3(luma_filter_3_phase[TAPS_3_phase], chroma_filter_3_phase[TAPS_3_phase], chroma_filter_3_phase[TAPS_3_phase]);
	wsum=wsum+wsum+tmps;
	signal+=texCD(PAAL_S02,tex_c).xyz*tmps;
	signal =signal/wsum;
	}
	signal.x=clamp( signal.x,0.0,1.0);
	if(ntsc_ring>0.05)
	{
	float2 dx=float2(OrgSize.z/min(res,1.0),0.0);
	float a=texCD(PAAL_S02,tex_c-2.0*dx).a;
	float b=texCD(PAAL_S02,tex_c-    dx).a;
	float c=texCD(PAAL_S02,tex_c+2.0*dx).a;
	float d=texCD(PAAL_S02,tex_c+    dx).a;
	float e=texCD(PAAL_S02,tex_c       ).a;
	signal.x=lerp(signal.x,clamp(signal.x,min(min(min(a,b),min(c,d)),e),max(max(max(a,b),max(c,d)),e)),ntsc_ring);
	}
	float x=get_luma(texCD(PAAL_S01, tex_c).rgb);
	return float4(signal,x);
}

float4 Signal_3_PS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 dx=float2(0.25*OrgSize.z/4.0,0.0);
	float2 xx=float2(0.50*OrgSize.z,0.0);
	float2 tex_c=texcoord+float2(0.5*OrgSize.z/4.0,0.0);float2 tcoord=tex_c-2.0*dx;
	float2 tcoorb=(floor(OrgSize.xy*tex_c)+0.5)*OrgSize.zw;
	float lcoord=OrgSize.x*(tex_c.x+dx.x )-0.5;
	float fpx=frac(lcoord);
	lcoord =(floor(lcoord)+0.5)*OrgSize.z;
	float3 ll1=texCD(PAAL_S03,tcoord+ xx).xyz;
	float3 ll2=texCD(PAAL_S03,tcoord- xx).xyz;
	float dy=0.0;
	xx=float2(OrgSize.z,0.0);
	float phase= (ntsc_phase<1.5)?((OrgSize.x>300.0)? 2.0:3.0):((ntsc_phase>2.5)?3.0:2.0);
	if(ntsc_phase==4.0)phase=3.0;
	float ca=texCD(PAAL_S02,tcoorb-xx-xx).a;
	float c0=texCD(PAAL_S02,tcoorb-xx   ).a;
	float c1=texCD(PAAL_S02,tcoorb      ).a;
	float c2=texCD(PAAL_S02,tcoorb+xx   ).a;
	float cb=texCD(PAAL_S02,tcoorb+xx+xx).a;
	float th=(phase<2.5)?0.025:0.0075;
	float line0=    swoothstep(th,0.0,min(abs(c1-c0),abs(c2-c1)));
	float line1=max(swoothstep(th,0.0,min(abs(ca-c0),abs(c2-cb))), line0 );
	float line2=max(swoothstep(th,0.0,min(abs(ca-c2),abs(c0-cb))), line1 );
	if( ntsc_rainbow>0.5&&phase<2.5)
	{
	float ybool1=1.0;bool ybool2=(c0==c1&&c1==c2);
	if((ntsc_rainbow<1.5)&&bool(line0))ybool1=0.0;else
	if((ntsc_rainbow<2.5)&&bool(line2))ybool1=0.0;else
	if(ybool2)ybool1=0.0;
	float liine_no=floor( mod(OrgSize.y*tex_c.y,2.0));
	float frame_no=floor( mod(float(framecount),2.0));
	float ii=abs(liine_no-frame_no);
	dy=ii*OrgSize.w*ybool1;
	}
	float3 ref=texCD(PAAL_S03,tcoord).xyz;
	float2 org=ref.yz;
	ref.yz= texCD(PAAL_S03,tcoord+float2(0.0,dy)).yz;
	float lum1=min(texCD(PAAL_S02,tex_c-dx).a, texCD(PAAL_S02,tex_c+dx).a);
	float lum2=ref.x ;
	float3 ll3=abs(ll1-ll2);
	float di=max(max(ll3.x,ll3.y),max(ll3.z,abs(ll1.x*ll1.x-ll2.x*ll2.x)));
	float df=pow(di,0.125);
	float lc=swoothstep(0.20,0.10,abs(lum2-lum1))*df;
	float tmp1=swoothstep(0.05-0.03*lc,0.425-0.375*lc,di);
	float tmp2=pow((tmp1+0.1)/1.1,0.25);
	float sweight=lerp(tmp1,tmp2,line0);
	float zweight=lerp(tmp1,tmp2,line2);
	float3 signal=ref;
	float ntzc_shrp= abs(ntsc_shrp);
	if(ntzc_shrp>0.25)
	{
	float mixer=sweight;
	if(ntsc_shrp>0.25)mixer=zweight; mixer*=0.1*ntzc_shrp;
	float lumix=lerp(lum2,lum1,mixer);
	float lm1=lerp(lum2*lum2 ,lum1*lum1 ,mixer);lm1=sqrt(lm1);
	float lm2=lerp(sqrt(lum2),sqrt(lum1),mixer);lm2=lm2* lm2 ;
	float k1=abs(lumix-lm1)+0.00001;
	float k2=abs(lumix-lm2)+0.00001;
	signal.x=min((k2*lm1+k1*lm2)/(k1+k2),1.0);
	signal.x=min(signal.x,max(ntsc_shpe*signal.x,lum2));
	}
	if((ntsc_charp1+ntsc_charp2)>0.25)
	{
	float mixer=sweight;
	if(ntsc_shrp>0.25)mixer=zweight;
	mixer =lerp(swoothstep(0.075,0.125,max(ll3.y,ll3.z)),swoothstep(0.015,0.0275,di),line2)*mixer;
	mixer*=0.1*((phase<2.5)? ntsc_charp1:ntsc_charp2);
	tcoord=float2(lcoord,tcoord.y);
	float3 origin=rgb2yiq(lerp(texCD(PAAL_S01,tcoord).rgb,texCD(PAAL_S01,tcoord+xx).rgb,clamp(1.5*fpx-0.25,0.0,1.0)));
	signal.yz=lerp(signal.yz,origin.yz,mixer);
	}
	if(ntsc_rainbow==2.0&&phase<2.5){signal.yz=lerp(signal.yz,org,zweight);}
	signal.x=pow(signal.x,1.0/ntsc_gamma);
	signal=clamp(yiq2rgb(signal),0.0,1.0);
	return float4(signal,1.0);
}

float4 SharpnessPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 g01=float2(-0.5*OrgSize.z,0.0);
	float2 g21=float2( 0.5*OrgSize.z,0.0);
	float3 c01=texCD(PAAL_S04,texcoord+g01).rgb;
	float3 c21=texCD(PAAL_S04,texcoord+g21).rgb;
	float3 c11=texCD(PAAL_S04,texcoord    ).rgb;
	float3 b11=0.5*(c01+c21);
	float contrast=max(max(c11.r,c11.g),c11.b);
	contrast=lerp(2.0*CCONTR,CCONTR,contrast);
	float3 nim=min(min(c01,c21),c11);float3 mn1=min(nim,c11*(1.0-contrast));
	float3 xam=max(max(c01,c21),c11);float3 mx1=max(xam,c11*(1.0+contrast));
	float3 di0=pow(mx1-mn1+0.00001,0.75);
	float3 sharpen=lerp(CSHARPEN*CDETAILS,CSHARPEN,di0);
	float3 res=clamp(lerp(c11,b11,-sharpen),mn1,mx1);
	if(DEBLUR>1.125)
	{
	float2 toxcoord=(floor(OrgSize.xy*texcoord)+0.5)*OrgSize.zw;
	float l01=get_luma(texCD(PAAL_S01,texcoord+2.0*g01).rgb);
	float l21=get_luma(texCD(PAAL_S01,texcoord+2.0*g21).rgb);
	float l11=get_luma(texCD(PAAL_S01,toxcoord        ).rgb);
	float d11=min(min(l01,l21),l11);
	l11=max(max(l01,l21),l11);
	float lmn=min(min(get_luma(c01),get_luma(c21)),get_luma(c11));float ln1=min(lerp(d11,lmn,lmn),lmn);
	float lmx=max(max(get_luma(c01),get_luma(c21)),get_luma(c11));float lx1=max(lerp(lmx,l11,lmx),lmx);
	float r11=get_luma(res);
	float di1=max((r11-ln1),0.0)+0.00001;di1=pow(di1,DEBLUR);
	float di2=max((lx1-r11),0.0)+0.00001;di2=pow(di2,DEBLUR);
	float ratio=di1/(di1+di2);
	float zharpen=lerp(ln1,lx1,ratio);
	zharpen=min(zharpen,max(DREDGE*zharpen,r11));
	res=rgb2yiq(res);
	d11=res.x;
	res.x=zharpen;
	res.x=clamp((1.0+ DSHARP)* res.x-DSHARP*d11,ln1*(1.0-contrast),lx1*(1.0+contrast));
	res=max(yiq2rgb(res),0.0);
	}
	return float4(res,1.0);
}

technique NTSC_Adaptive
{
	pass StockPass
	{
	VertexShader=PostProcessVS;
	PixelShader=StockPassPS;
	RenderTarget=PAAL_T01;
	}
	pass NTSCPASS1
	{
	VertexShader=PostProcessVS;
	PixelShader=Signal_1_PS;
	RenderTarget=PAAL_T02;
	}
	pass NTSCPASS2
	{
	VertexShader=PostProcessVS;
	PixelShader=Signal_2_PS;
	RenderTarget=PAAL_T03;
	}
	pass NTSCPASS3
	{
	VertexShader=PostProcessVS;
	PixelShader=Signal_3_PS;
	RenderTarget=PAAL_T04;
	}
	pass Sharpness
	{
	VertexShader=PostProcessVS;
	PixelShader=SharpnessPS;
	}
}