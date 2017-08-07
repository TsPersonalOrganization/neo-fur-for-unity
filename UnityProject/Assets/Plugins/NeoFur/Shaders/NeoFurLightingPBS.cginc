
#ifndef NEO_FUR_LIGHTING_PBS_INCLUDED
#define NEO_FUR_LIGHTING_PBS_INCLUDED

float HairA(float B, float Theta)
{
	return exp(-0.5 * (Theta * Theta) / (B * B)) / (sqrt(2 * UNITY_PI) * B);
}

float HairB(float CosTheta)
{
	const float n = 1.55;
	float t = (1 - n) / (1 + n);
	const float F0 = t * t;
	return F0 + (1 - F0) * pow(1 - CosTheta, 5);
}

float3 HairShading(float smoothness, float3 specular, float3 albedo, float3 lightVec, float3 viewVec, half3 normal, float shadow, float scatterAmount)
{
	albedo = max(albedo, 0.00001);

	float roughness = 1.0 - smoothness;
	float roughnessSqr = roughness * roughness;
	//normal = -normal;
	float vDotL = dot(viewVec, lightVec);
	float sinThetaL = dot(normal, lightVec);
	float sinThetaV = dot(normal, viewVec);
	float cosThetaD = cos(0.5 * abs(asin(sinThetaV) - asin(sinThetaL)));

	float3 lp = lightVec - sinThetaL * normal;
	float3 vp = viewVec - sinThetaV * normal;
	float cosPhi = dot(lp, vp) * rsqrt(dot(lp, lp) * dot(vp, vp) + 0.0001);
	float cosHalfPhi = sqrt(saturate(0.5 + 0.5 * cosPhi));
	float phi = acos(cosPhi);

	float shift = 0.035;

	float3 color = 0;

	//R
	float rb = roughnessSqr;
	float rlocalShift = -1 * shift * 2;

	float rsa = sin(rlocalShift);
	float rca = cos(rlocalShift);
	float shiftValue = (2 * rsa * rca) * cosHalfPhi * sqrt(1 - sinThetaV * sinThetaV) + (2 * rsa * rsa) * sinThetaV;

	float rmp = HairA(rb * sqrt(2.0) * cosHalfPhi, sinThetaL + sinThetaV - shiftValue);
	float rnp = 0.25 * cosHalfPhi;
	float rfp = HairB(sqrt(saturate(0.5 + 0.5 * vDotL)));

	color += rmp * rnp * rfp * (specular * 2);

	//TT
	float nPrime = 1.2 / cosThetaD + 0.35 * cosThetaD;
	float tta = 1 / nPrime;
	float tth = cosHalfPhi * rsqrt(1 + tta * tta - 2 * tta * sqrt(0.5 - 0.5 * cosPhi));
	float ryt = asin(tth / nPrime);
	float ttf = HairB(cosThetaD * sqrt(saturate(1 - tth * tth)));

	float ttfp = pow(1 - ttf, 2);
	float3 tttp = pow(albedo, 0.5 * cos(ryt) / cosThetaD);
	float tts = 0.3;
	float ttnp = exp((phi - UNITY_PI) / tts) / (tts * pow(1 + exp((phi - UNITY_PI) / tts), 2));

	float ttb = roughnessSqr / 2;
	float ttlocalShift = shift;

	float ttmp = HairA(ttb, sinThetaL + sinThetaV - ttlocalShift);

	color += ttmp * ttnp * ttfp * tttp;

	//TRT
	float trtf = HairB(cosThetaD * 0.5);
	float trtfp = pow(1 - trtf, 2) * trtf;
	float3 trttp = pow(albedo, 0.8 / cosThetaD);
	float trtnp = (1 / UNITY_PI) * 2.6 * exp(2 * 2.6 * (cosPhi - 1));

	float trtb = roughnessSqr * 2;
	float trtlocalShift = shift * 4;
	float trtmp = HairA(trtb, sinThetaL + sinThetaV - trtlocalShift);

	color += trtmp * trtnp * trtfp * trttp;

	//Scattering
	normal = normalize(viewVec - normal * dot(viewVec, normal));

#if 1
	float wrap = lerp(0.1, 5.25, scatterAmount);
	float nDotL = dot(normal, lightVec) + wrap;
	nDotL = nDotL < 0 ? -1 * nDotL * 0.25 : nDotL;
	nDotL = saturate(((nDotL) * wrap) / pow(1 + wrap, 2));
#else
	float wrap = 1;
	float nDotL = saturate((dot(normal, lightVec) + wrap) / pow(1 + wrap, 2));
#endif

	float scatter = (1 / UNITY_PI) * nDotL * scatterAmount;
	float luma = max(Luminance(albedo), 0.00001);
	float3 scatterTint = pow(albedo / luma, 1 - shadow);
	color += sqrt(albedo) * scatter * scatterTint;

	return color;
}

inline half4 FurStandardCommon(float3 albedo, float3 bentNormal, float3 vertexNormal, float scatter, float oneMinusReflectivity, float smoothness, float occlusion, half3 viewDir, UnityGI gi)
{
	bentNormal = normalize(bentNormal);
	
	float specular = 0.5;

	//Since we dont have subsurface shadows this helps soften the light falloff edges.
	//This also masks out light on the back side of objects when the light doesnt have shadows enabled.
	float shadow = saturate((dot(normalize(vertexNormal + bentNormal), gi.light.dir) + 0.2) * 8);
	gi.light.color *= shadow;

	float3 hairShading = HairShading(smoothness, specular, albedo, gi.light.dir, viewDir, bentNormal, shadow * occlusion, scatter * occlusion);
	//because it matches brightness of standard shaded objects better.
	hairShading *= 2.5;

	half4 c = 0;
	c.rgb = hairShading * gi.light.color;
	c.rgb += albedo * gi.indirect.diffuse;

	return c;

}

#include "NeoFurLightingCommon.cginc"

#endif