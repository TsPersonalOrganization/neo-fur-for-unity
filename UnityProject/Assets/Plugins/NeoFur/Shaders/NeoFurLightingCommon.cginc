#ifndef NEO_FUR_LIGHTING_COMMON_INCLUDED
#define NEO_FUR_LIGHTING_COMMON_INCLUDED


void DoFurAmbientOcclusion(inout SurfaceOutputNeoFur s)
{
	//fur alpha stored in occlusion from FurSurf
	float	furAlpha = s.Occlusion;

	//ambient occlusion for fur nearer the object surface
	float	AO = lerp(furAlpha, 1, (1.0 - _AOValue));

	s.Occlusion = AO;	//store AO back in occlusion
}

//custom lighting function for forward
//mostly copied from Unity standard shader
half4 LightingFurStandard(SurfaceOutputNeoFur s, half3 viewDir, UnityGI gi)
{
	DoFurAmbientOcclusion(s);

	half4 c = FurStandardCommon(s.Albedo, s.BentNormal, s.Normal, s.Scatter, 1, s.Smoothness, s.Occlusion, viewDir, gi);

	return c;
}

inline half4 LightingFurStandard_Deferred(SurfaceOutputNeoFur s, half3 viewDir, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal)
{
	DoFurAmbientOcclusion(s);

	float2 packedNormal = NormalToSpherical(s.BentNormal);
	packedNormal = packedNormal*0.5 + 0.5;

	outDiffuseOcclusion = half4(s.Albedo, s.Occlusion);
	outSpecSmoothness = half4(s.Scatter, packedNormal, s.Smoothness);
	outNormal = half4(s.Normal * 0.5 + 0.5, 0);
	half4 emission = half4(s.Emission + s.Albedo*gi.indirect.diffuse, 1);
	return emission;
}


inline void LightingFurStandard_GI(
	SurfaceOutputNeoFur s,
	UnityGIInput data,
	inout UnityGI gi)
{
	DoFurAmbientOcclusion(s);

	UNITY_GI(gi, s, data);
}

#endif