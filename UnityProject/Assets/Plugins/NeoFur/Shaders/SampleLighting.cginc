#ifndef SAMPLE_LIGHTING_INCLUDED
#define SAMPLE_LIGHTING_INCLUDED

#define	CEL0	0.05
#define	CEL1	0.5
#define CEL2	0.8

float Celify1(float val)
{
	if(val < CEL0)
	{
		return	CEL0;
	}
	else if(val < CEL1)
	{
		return	CEL1;
	}
	else if(val < CEL2)
	{
		return	CEL2;
	}
	else
	{
		return	1;
	}
}


void Celify(inout half3 val)
{
	val.x	=Celify1(val.x);
	val.y	=Celify1(val.y);
	val.z	=Celify1(val.z);
}

//simple little goofy rampy example lighting
half4 LightingCel(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
{
	s.Normal = normalize(s.Normal);

	DoFurAmbientOcclusion(s);

	half3	lightVal	=gi.light.ndotl * 2 * gi.light.color * s.Occlusion;

	Celify(lightVal);

	half4	c;
	c.rgb	=s.Albedo * lightVal;
	c.a		=s.Alpha;

	return c;
}


inline half4 LightingCel_Deferred (SurfaceOutputStandard s, half3 viewDir, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal)
{
	DoFurAmbientOcclusion(s);

	half3	lightVal	=gi.light.ndotl * 2 * gi.light.color * s.Occlusion;

	Celify(lightVal);

	half4	c;
	c.rgb	=s.Albedo * lightVal;
	c.a		=s.Alpha;

	outDiffuseOcclusion = half4(s.Albedo, s.Occlusion);
	outSpecSmoothness = half4(gi.light.color, s.Smoothness);
	outNormal = half4(s.Normal * 0.5 + 0.5, 1);

	half4 emission = half4(s.Emission + c.rgb, 1);
	return emission;
}


inline void LightingCel_GI (
	SurfaceOutputStandard s,
	UnityGIInput data,
	inout UnityGI gi)
{
	DoFurAmbientOcclusion(s);

	UNITY_GI(gi, s, data);
}


//wacky CGA looking effect
half4 LightingWacky(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
{
	s.Normal = normalize(s.Normal);

	//rim to boost light around fur edges
	float3	rimLight	=lerp(0.0, pow(1.0 - max(0, dot(s.Normal, viewDir)),
							_RimLightExponent), _RimLightStrength);

	DoFurAmbientOcclusion(s);

	//standard lighting from unity
	half oneMinusReflectivity;
	half3 specColor;
	s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

	//add in rim here?
	s.Albedo	+=rimLight;

	//wacky time stuff
	s.Albedo.x	+=_Time;
	s.Albedo.y	+=_SinTime;
	s.Albedo.z	+=_CosTime;

	// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
	// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
	half outputAlpha;
	s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

	half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	c.rgb += UNITY_BRDF_GI (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, s.Occlusion, gi);
	c.a = outputAlpha;
	return c;
}


inline half4 LightingWacky_Deferred (SurfaceOutputStandard s, half3 viewDir, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal)
{
	float3	rimLight	=lerp(0.0, pow(1.0 - max(0, dot(s.Normal, viewDir)),
							_RimLightExponent), _RimLightStrength);

	DoFurAmbientOcclusion(s);

	//standard lighting from unity
	half oneMinusReflectivity;
	half3 specColor;
	s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

	//add in rim here?
	s.Albedo	+=rimLight;

	//wacky time stuff
	s.Albedo.x	+=_Time;
	s.Albedo.y	+=_SinTime;
	s.Albedo.z	+=_CosTime;

	half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	c.rgb += UNITY_BRDF_GI (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, s.Occlusion, gi);

	outDiffuseOcclusion = half4(s.Albedo, s.Occlusion);
	outSpecSmoothness = half4(specColor, s.Smoothness);
	outNormal = half4(s.Normal * 0.5 + 0.5, 1);
	half4 emission = half4(s.Emission + c.rgb, 1);
	return emission;
}


inline void LightingWacky_GI (
	SurfaceOutputStandard s,
	UnityGIInput data,
	inout UnityGI gi)
{
	DoFurAmbientOcclusion(s);

	UNITY_GI(gi, s, data);
}
#endif