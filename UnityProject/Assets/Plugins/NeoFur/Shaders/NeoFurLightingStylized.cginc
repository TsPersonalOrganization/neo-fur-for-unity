#ifndef NEO_FUR_LIGHTING_STYLIZED_INCLUDED
#define NEO_FUR_LIGHTING_STYLIZED_INCLUDED

inline half4 FurStandardCommon(float3 albedo, float3 normal, float3 specColor, float oneMinusReflectivity, float smoothness, float occlusion, float alpha, half3 viewDir, UnityGI gi, float shadow)
{
	normal = normalize(normal);

	//rim to boost light around fur edges
	float rim = min(1, max(0, dot(normal, viewDir)));
	float edge = pow(1.0 - rim, _RimLightExponent) * _FuzzBrightness;
	float darkened = 1.0 - _FuzzCenterDarkness * rim;
	float4 rimLight = _FuzzRimColor * edge + darkened;

	// multiply in the edge lightening and core darkening according to mix factor
	albedo = lerp(albedo, albedo * rimLight, _RimLightStrength);

	half4 c = UNITY_BRDF_PBS(albedo, specColor, oneMinusReflectivity, smoothness, normal, viewDir, gi.light, gi.indirect);
	c.rgb += UNITY_BRDF_GI(albedo, specColor, oneMinusReflectivity, smoothness, normal, viewDir, occlusion, gi);
	//c = rimLight;
	return c;

}

#include "NeoFurLightingCommon.cginc"

#endif