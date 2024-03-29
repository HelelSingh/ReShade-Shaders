uniform float quality <
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 0.0;
	ui_step = 1.0;
	ui_label = "Values (Info Only): SVideo = 0 | Composite = 1.0 | RF = 2.0";
> = 0.0;

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
	ui_min = 1.0;
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
	ui_min = -1.0;
	ui_max = 1.0;
	ui_step = 0.1;
	ui_label = "NTSC Coloring/Rainbow Effect";
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
	ui_label = "NTSC Sharpness (Negative:Adaptive)";
> = 0.0;

uniform float ntsc_shpe <
	ui_type = "drag";
	ui_min = 0.5;
	ui_max = 1.0;
	ui_step = 0.05;
	ui_label = "NTSC Sharpness Shape";
> = 0.75;

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
	ui_label = "FSharpen - Sharpen Contrast/Ringing";
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

#include "ReShade.fxh"

#define TexSize float2(1.0*Resolution_X,Resolution_Y)
#define IptSize float2(4.0*Resolution_X,Resolution_Y)
#define OrgSize float4(TexSize,1.0/TexSize)
#define SrcSize float4(IptSize,1.0/IptSize)
#define pii 3.14159265
#define mix_m float3x3(BRIGHTNESS,ARTIFACT,ARTIFACT,FRINGING,2.0*SATURATION,0.0,FRINGING,0.0,2.0*SATURATION)
#define rgb_m float3x3(0.299,0.587,0.114,0.596,-0.274,-0.322,0.211,-0.523,0.312)
#define yiq_m float3x3(1.000,0.956,0.621,1.000,-0.272,-0.647,1.000,-1.106,1.703)
#define tex_1 texcoord-float2(0.25*OrgSize.z/4.0,0.0)
#define tex_2 texcoord-float2(0.25*OrgSize.z/4.0,0.0)
#define fetch_offset1(dx) tex2Dlod(PAAL_S02,float4(tex_1+dx,0,0)).xyz+tex2Dlod(PAAL_S02,float4(tex_1-dx,0,0)).xyz
#define fetch_offset2(dx) float3(tex2Dlod(PAAL_S02,float4(tex_1+dx.xz,0,0)).x+tex2Dlod(PAAL_S02,float4(tex_1-dx.xz,0,0)).x,tex2Dlod(PAAL_S02,float4(tex_1+dx.yz,0,0)).yz+tex2Dlod(PAAL_S02,float4(tex_1-dx.yz,0,0)).yz)

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
	return dot(c,float3(0.2989,0.5870,0.1140));
}

float4 EmptyPassPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	return tex2D(PAAL_S00,texcoord.xy);
}

float4 Signal_1_PS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float pix_res= min(ntsc_scale,1.0);
	float phase= (ntsc_phase<1.5)?((OrgSize.x>300.0)? 2.0:3.0):((ntsc_phase>2.5)?3.0:2.0);
	if(ntsc_phase==4.0)phase=3.0;
	float res=ntsc_scale;
	float mod1=2.0;
	float mod2=3.0;
	float CHROMA_MOD_FREQ=(phase<2.5)?(4.0*pii/15.0):(pii/3.0);
	float ARTIFACT=cust_artifacting;
	float FRINGING=cust_fringing;
	float BRIGHTNESS=ntsc_brt;
	float SATURATION=ntsc_sat;
	float MERGE=0.0;
	float mix1=0.0;
	if(ntsc_fields== 1.0&&phase==3.0) MERGE=1.0;else
	if(ntsc_fields== 2.0) MERGE=0.0;else
	if(ntsc_fields== 3.0) MERGE=1.0;
	float2 pix_no=texcoord*OrgSize.xy*pix_res* float2(4.0,1.0);
	float3 col0=tex2D(PAAL_S01, texcoord).rgb;
	float3 yiq1=rgb2yiq(col0);float c0=yiq1.x;
	yiq1.x=pow(yiq1.x,ntsc_gamma); float lum=yiq1.x;
	float2 dx=float2(OrgSize.z,0.0);
	float3 c1=tex2D(PAAL_S01,texcoord-dx).rgb;
	float3 c2=tex2D(PAAL_S01,texcoord+dx).rgb;
	if(abs(ntsc_rainbow)>0.025)
	{
	float2 dy=float2(0.0,OrgSize.w);
	float3 c3=tex2D(PAAL_S01,texcoord+dy).rgb;
	float3 c4=tex2D(PAAL_S01,texcoord+dx+dy ).rgb;
	float3 c5=tex2D(PAAL_S01,texcoord+dx+dx ).rgb;
	float3 c6=tex2D(PAAL_S01,texcoord+dx*3.0).rgb;
	c1.x=get_luma(c1);
	c2.x=get_luma(c2);
	c3.x=get_luma(c3);
	c4.x=get_luma(c4);
	c5.x=get_luma(c5);
	c6.x=get_luma(c6);
	float mix2=min(5.0*min(min(abs(c0-c1.x),abs(c0-c2.x)),min(abs(c2.x-c5.x),abs(c5.x-c6.x))),1.0);
	float bar1=1.0-min(7.0*min(max(max(c0,c3.x)-0.15,0.0),max(max(c2.x,c4.x)-0.15,0.0)),1.0);
	float bar2=step(abs(c1.x-c2.x)+abs(c0-c5.x)+abs(c2.x-c6.x),0.325);
	mix1=bar1*bar2*mix2*(1.0-min(10.0*min(abs(c0-c3.x),abs(c2.x-c4.x)),1.0));
	mix1=mix1*ntsc_rainbow;
	}
	if(ntsc_phase==4.0)
	{
	float mix3=min(5.0*abs(c1.x-c2.x),1.0);
	c1.x=pow(c1.x,ntsc_gamma);
	c2.x=pow(c2.x,ntsc_gamma);
	yiq1.x=lerp(min(0.5*(yiq1.x+max(c1.x,c2.x)),max(yiq1.x,min(c1.x,c2.x))),yiq1.x,mix3);
	}
	float3 yiq2=yiq1;
	float3 yiqs=yiq1;
	float3 yiqz=yiq1;
	float taps_comp=1.0+ 2.0*step(ntsc_taps,15.5);
	if(MERGE>0.5)
	{
	float chroma_phase2=(phase<2.5)?pii*(mod(pix_no.y,mod1)+mod(framecount+1,2.)):0.6667*pii*(mod(pix_no.y,mod2)+mod(framecount+1,2.));
	float mod_phase2=chroma_phase2 *(1.0-mix1)+pix_no.x*CHROMA_MOD_FREQ*taps_comp;
	float i_mod2=cos(mod_phase2);
	float q_mod2=sin(mod_phase2);
	yiq2.yz*=float2(i_mod2,q_mod2);
	yiq2=mul(mix_m,yiq2);
	yiq2.yz*=float2(i_mod2,q_mod2);
	if(res>1.025)
	{
	mod_phase2=chroma_phase2 *(1.0-mix1) +res *pix_no.x*CHROMA_MOD_FREQ*taps_comp;
	i_mod2=cos(mod_phase2);
	q_mod2=sin(mod_phase2);
	yiqs.yz*=float2(i_mod2,q_mod2);
	yiq2.x=dot(yiqs,mix_m[0]);
	}
	}
	float chroma_phase1=(phase<2.5)?pii*(mod(pix_no.y,mod1)+mod(framecount  ,2.)):0.6667*pii*(mod(pix_no.y,mod2)+mod(framecount  ,2.));
	float mod_phase1=chroma_phase1 *(1.0-mix1)+pix_no.x*CHROMA_MOD_FREQ*taps_comp;
	float i_mod1=cos(mod_phase1);
	float q_mod1=sin(mod_phase1);
	yiq1.yz*=float2(i_mod1,q_mod1);
	yiq1=mul(mix_m,yiq1);
	yiq1.yz*=float2(i_mod1,q_mod1);
	if(res>1.025)
	{
	mod_phase1=chroma_phase1 *(1.0-mix1) +res *pix_no.x*CHROMA_MOD_FREQ*taps_comp;
	i_mod1=cos(mod_phase1);
	q_mod1=sin(mod_phase1);
	yiqz.yz*=float2(i_mod1,q_mod1);
	yiq1.x=dot(yiqz,mix_m[0]);
	}
	if(ntsc_phase==4.0){yiq1.x=lum;yiq2.x=lum;}
	yiq1=(MERGE<0.5)?yiq1:0.5*(yiq1+yiq2);
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
	float phase= (ntsc_phase<1.5)?((OrgSize.x>300.0)? 2.0:3.0):((ntsc_phase>2.5)?3.0:2.0);
	if(ntsc_phase==4.0){phase=3.0;luma_filter_3_phase=luma_filter_4_phase;}
	float3 wsum =0.0.xxx;
	float3 sums=wsum;
	float3 tmps=wsum;
	float offset=0.0; int i=0; float j=0.0;
	if(phase<2.5)
	{
	float loop=max(ntsc_taps,8.0);
	float2 dx=float2(one.x,0.0);
	float2 xd=dx;int loopstart=int(TAPS_2_phase-loop);float taps=0.0;
	float laps=ntsc_taps+1.0;
	float ssub=loop-loop/ntsc_cscale1;
	for(i=loopstart;i<32;i++)
	{
	offset=float(i-loopstart);
	j=offset+1.0; xd=(offset-loop)*dx;
	sums=fetch_offset1(xd);
	taps=max(j-ssub,0.0);
	tmps=float3(luma_filter_2_phase[i],taps.xx);
	wsum=wsum+tmps; signal+=sums*tmps;
	}
	taps=laps-ssub;
	tmps=float3(luma_filter_2_phase[TAPS_2_phase],taps.xx);
	wsum=wsum+wsum+tmps;
	signal+=tex2D(PAAL_S02,tex_1).xyz*tmps;
	signal =signal/wsum;
	}else{
	float loop=min(ntsc_taps,TAPS_3_phase); one.y=one.y/ntsc_cscale2;
	float3 dx=float3(one.x,one.y,0.0);
	float3 xd=dx;int loopstart=int(24.0-loop);
	for(i=loopstart;i<24;i++)
	{
	offset=float(i-loopstart);
	j=offset+1.0;xd.xy=(offset-loop)*dx.xy;
	sums=fetch_offset2(xd);
	tmps=float3(luma_filter_3_phase[i], chroma_filter_3_phase[i].xx);
	wsum=wsum+tmps; signal+=sums*tmps;
	}
	tmps=float3(luma_filter_3_phase[TAPS_3_phase],chroma_filter_3_phase[TAPS_3_phase],chroma_filter_3_phase[TAPS_3_phase]);
	wsum=wsum+wsum+tmps;
	signal+=tex2D(PAAL_S02,tex_1).xyz*tmps;
	signal =signal/wsum;
	}
	if(ntsc_ring>0.05)
	{
	float2 dx=float2(OrgSize.z/min(res,1.0),0.0);
	float a=tex2D(PAAL_S02,tex_1-1.5*dx).a;
	float b=tex2D(PAAL_S02,tex_1-0.5*dx).a;
	float c=tex2D(PAAL_S02,tex_1+1.5*dx).a;
	float d=tex2D(PAAL_S02,tex_1+0.5*dx).a;
	float e=tex2D(PAAL_S02,tex_1       ).a;
	signal.x=lerp(signal.x,clamp(signal.x,min(min(min(a,b),min(c,d)),e),max(max(max(a,b),max(c,d)),e)),ntsc_ring);
	}
	float3 x=rgb2yiq(tex2D(PAAL_S01,tex_1).rgb);
	signal.x=clamp(signal.x,-1.0,1.0);
	float3 rgb=signal;
	return float4(rgb,x.x);
}

float4 Signal_3_PS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 dx=float2(0.25*OrgSize.z,0.0)/4.0;
	float2 tcoord=tex_2+dx;
	float2 offset=float2(0.5*OrgSize.z,0.0);
	float3 ll1=tex2D(PAAL_S03,tcoord+     offset).xyz;
	float3 ll2=tex2D(PAAL_S03,tcoord-     offset).xyz;
	float3 ll3=tex2D(PAAL_S03,tcoord+0.50*offset).xyz;
	float3 ll4=tex2D(PAAL_S03,tcoord-0.50*offset).xyz;
	float3 ref=tex2D(PAAL_S03,tcoord).xyz;
	float lum1=min(tex2D(PAAL_S03,tex_2-dx).a, tex2D(PAAL_S03,tex_2+dx).a);
	float lum2=max(ref.x,0.0);
	float dif=max(max(abs(ll1.x-ll2.x),abs(ll1.y-ll2.y)),max(abs(ll1.z-ll2.z),abs(ll1.x*ll1.x-ll2.x*ll2.x)));
	float dff=max(max(abs(ll3.x-ll4.x),abs(ll3.y-ll4.y)),max(abs(ll3.z-ll4.z),abs(ll3.x*ll3.x-ll4.x*ll4.x)));
	float lc=(1.0-smoothstep(0.10,0.20,abs(lum2-lum1)))*pow(dff,0.125);
	float sweight=smoothstep(0.05-0.03*lc,0.45-0.40*lc,dif);
	float3 signal=ref;
	if(abs(ntsc_shrp)>-0.1)
	{
	float lummix=lerp(lum2,lum1,0.1*abs(ntsc_shrp));
	float lm1=lerp(lum2*lum2 ,lum1*lum1 ,0.1*abs(ntsc_shrp));lm1=sqrt(lm1);
	float lm2=lerp(sqrt(lum2),sqrt(lum1),0.1*abs(ntsc_shrp));lm2=lm2* lm2 ;
	float k1=abs(lummix-lm1)+0.00001;
	float k2=abs(lummix-lm2)+0.00001;
	lummix=min((k2*lm1+k1*lm2)/(k1+k2),1.0);
	signal.x=lerp(lum2,lummix,smoothstep(0.25,0.4,pow(dff,0.125)));
	signal.x=min(signal.x,max(ntsc_shpe*signal.x,lum2));
	}else
	signal.x=clamp(signal.x,0.0,1.0);
	float3 rgb=signal;
	if(ntsc_shrp<-0.1)
	{
	rgb.x=lerp(ref.x,rgb.x,sweight);
	}
	rgb.x=pow(rgb.x,1.0/ntsc_gamma);
	rgb=clamp(yiq2rgb(rgb),0.0,1.0);
	return float4(rgb,1.0);
}

float4 SharpnessPS(float4 position:SV_Position,float2 texcoord:TEXCOORD):SV_Target
{
	float2 g01=float2(-0.5*OrgSize.z,0.0);
	float2 g21=float2( 0.5*OrgSize.z,0.0);
	float3 c01=tex2D(PAAL_S04,texcoord+g01).rgb;
	float3 c21=tex2D(PAAL_S04,texcoord+g21).rgb;
	float3 c11=tex2D(PAAL_S04,texcoord    ).rgb;
	float3 b11=0.5*(c01+c21);
	float contrast=max(max(c11.r,c11.g),c11.b);
	contrast=lerp(2.0*CCONTR,CCONTR,contrast);
	float3 mn=min(min(c01,c21),c11);float3 mn1=min(mn,c11*(1.0-contrast));
	float3 mx=max(max(c01,c21),c11);float3 mx1=max(mx,c11*(1.0+contrast));
	float3 dif=pow(mx1-mn1+0.0001,0.75);
	float3 sharpen=lerp(CSHARPEN*CDETAILS,CSHARPEN,dif);
	float3 res=clamp(lerp(c11,b11,-sharpen),mn1,mx1);
	if(DEBLUR>1.125)
	{
	c01=tex2D(PAAL_S01,texcoord+2.0*g01).rgb;
	c21=tex2D(PAAL_S01,texcoord+2.0*g21).rgb;
	c11=tex2D(PAAL_S01,texcoord        ).rgb;
	mn1=sqrt(min(min(c01,c21),c11)*mn);
	mx1=sqrt(max(max(c01,c21),c11)*mx);
	float3 dif1=max(res-mn1,0.0)+0.00001;dif1=pow(dif1,DEBLUR.xxx);
	float3 dif2=max(mx1-res,0.0)+0.00001;dif2=pow(dif2,DEBLUR.xxx);
	float3 ratio=dif1/(dif1+dif2);
	sharpen=min(lerp(mn1,mx1,ratio),pow(res,lerp(0.75.xxx,1.10.xxx,res)));
	res=rgb2yiq(res);
	res.x=dot(sharpen,float3(0.2989,0.5870,0.1140));
	res=max(yiq2rgb(res),0.0);
	}
	return float4(res,1.0);
}

technique NTSC_Adaptive
{
	pass EmptyPass
	{
	VertexShader=PostProcessVS;
	PixelShader=EmptyPassPS;
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