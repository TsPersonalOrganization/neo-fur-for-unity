#ifndef FUR_SETUP_INCLUDED
#define FUR_SETUP_INCLUDED

#include "UnityPBSLighting.cginc"
#include "NeoFurInput.cginc"
#include "NeoFurUtility.cginc"

float GetDitherPattern(float2 screenUV)
{
	float2 pixelUV = screenUV * _ScreenParams.xy;
	float mod = Repeat((int)(pixelUV.x + pixelUV.y + _NeoFur_JitterFrameCount), 2);
	mod = mod * 1 - 0.5;
	float mod2 = Repeat((int)(pixelUV.x / 2 + pixelUV.y / 2 + _NeoFur_JitterFrameCount / 2), 2);
	mod *= mod2 * 0.5 + 0.5;
	return mod;
}

// fake AO based on fur noise pattern
float FurNoiseAO(float strandMapSampleR, float aoPattern, float aoPatternDarkness, float heightMapSampleR)
{
	float oneMinusDarkness = 1 - aoPatternDarkness;
	float oneMinusPattern = 1 - aoPattern;
	float oneMinus = lerp(oneMinusDarkness, oneMinusPattern, heightMapSampleR);
	float ao = lerp(strandMapSampleR, 1, oneMinus);
	return ao;
}

float UseAlphaAsAO(float strandMapSampleR, float aoFactor)
{
	float clampedPattern = clamp(strandMapSampleR, .5, 1);

	return lerp(1, clampedPattern, aoFactor);
}

float GetStrandLengthAO(float aoFactor, float shellID, float lengthUND, float lengthOVR, fixed bOVRStrand)
{
	return lerp(lengthUND, lengthOVR, bOVRStrand) * shellID * aoFactor;
}

void FurAlphaSetup(float shellCount, float totalShellCount, float curShell,
	out float curAlpha, out float thicken)
{
	// Artificial thickness increase for lower-res LODs.
	thicken = 1.0f - (float(shellCount) / float(totalShellCount));
	thicken = saturate(thicken);
	thicken = 1.0f + thicken * 5.0f;

	float	furDelta = 1.0f / (shellCount - 1);

	//a small offset to prevent z fighting on the innermost shell
	float	firstOffs = furDelta / 2.0f;

	//step in shell alpha, 1 to stepAmount (never goes 0)
	float	alphaDelta = 1.0f / (shellCount + 1);
	float	curFur = (furDelta * curShell) + firstOffs;

	curAlpha = alphaDelta * (curShell + 1);
}

#ifdef COMPLEXFUR
void FurComplexAlphaSetup(float shellCount, float totalShellCount, float curShell,
	out float curAlpha, out float thicken)
{
	// Artificial thickness increase for lower-res LODs.
	thicken = 1.0f - (float(shellCount) / float(totalShellCount));
	thicken = saturate(thicken);
	thicken = 1.0f + thicken * 5.0f;

	//step in shell alpha, 1 to stepAmount (never goes 0)
	float	alphaDelta = 1.0f / (shellCount + 1);

	curAlpha = alphaDelta * curShell;
}
#endif

float3 GetPositionForShell(float shellAlpha, float3 skinPos, float3 guideVector, float3 cpPos, float bendExponent, float shellFade, float shellDist)
{
	float	blendPointAlpha = 1.0 - pow(1.0 - shellAlpha, bendExponent);
	float3	blendPoint =
		(1.0 - blendPointAlpha) * (skinPos + guideVector * _NeoFur_ShellDistance) +
		blendPointAlpha * cpPos;

	float	posAlpha = shellAlpha * shellFade * _NeoFur_VisibleLengthScale;

	//trying something new
	//do this ratio in "guide normalized space"
	//where the control point rest pos is near the guide endpoint
	float3	furPos = (1.0 - posAlpha) * skinPos + posAlpha * blendPoint;

	return	furPos;
}

static float shellJitters[8] =
{
	0.0 / 8.0,
	4.0 / 8.0,
	2.0 / 8.0,
	6.0 / 8.0,
	1.0 / 8.0,
	5.0 / 8.0,
	3.0 / 8.0,
	7.0 / 8.0
};

void DoFurMath(float curShell, float3 cpPosition, float3 guideVector, inout InputVS v, inout Input o)
{
	UNITY_INITIALIZE_OUTPUT(Input, o);

#if !defined(UNITY_PASS_SHADOWCASTER)
	if (_NeoFur_JitterFrameCount > 0)
	{
		int frameCount = (int)_NeoFur_JitterFrameCount;
		curShell += shellJitters[Repeat(frameCount, 8)];
	}
#endif

	float3 previousVertex = v.vertex.xyz;

	float	curAlpha, thickenAmount;

#ifdef COMPLEXFUR
	FurComplexAlphaSetup(_NeoFur_ShellCount, _NeoFur_TotalShellCount, curShell,
		curAlpha, thickenAmount);
#else

	FurAlphaSetup(_NeoFur_ShellCount, _NeoFur_TotalShellCount, curShell,
		curAlpha, thickenAmount);
#endif

	v.vertex.xyz = GetPositionForShell(curAlpha, v.vertex.xyz, guideVector, cpPosition, _NeoFur_BendExponent, _NeoFur_ShellFade, _NeoFur_ShellDistance);
	o.texcoord.zw = float2(pow(curAlpha, thickenAmount), curAlpha);

	//world transform computed position
	float4	wPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1));
	wPos.xyz /= wPos.w;
	o.viewDir = UnityWorldSpaceViewDir(wPos);

	float furDelta = 1.0f / (_NeoFur_ShellCount - 1);
	previousVertex = GetPositionForShell(curAlpha - furDelta, previousVertex, guideVector, cpPosition, _NeoFur_BendExponent, _NeoFur_ShellFade, _NeoFur_ShellDistance);

	v.normal = normalize(v.normal);
	v.tangent.xyz = normalize(v.tangent.xyz);

	//Set by surface shader code generation, but need to initialize.
	o.screenPos = 0;

	o.texcoord.xy = v.texcoord.xy;
	float3 bentNormal = lerp(v.normal, normalize(v.vertex.xyz - previousVertex), _NeoFur_NormalDirectionBlend);
	o.bentWorldNormal = normalize(RotateByProjection(unity_ObjectToWorld, bentNormal));
}

#ifndef COMPLEXFUR
//fewer texture reads
float NeoFur_Alpha(float texcoord2R, float strandMapSampleR, float growthSampleR)
{
	float strandMultHeight = strandMapSampleR * growthSampleR;

#ifdef MOBILEFUR
	float offset = (texcoord2R + _StrandAlphaOffset);
#else
	float offset = (texcoord2R + .001);
#endif

	return strandMultHeight - offset;
}
#endif




// Applies an SCurve image adjustment
float SCurve(float curvePower, float input)
{
	float oneHalf = .5;
	float a = pow(saturate(2 * input), curvePower) * oneHalf;
	float b1 = (1 - pow(1 - saturate(2 * (input - oneHalf)), curvePower));
	float b = b1 * oneHalf + oneHalf;
	float alpha = saturate(500 * b1);

	return lerp(a, b, alpha);
}

#ifndef COMPLEXFUR
//had no luck with functionalizing individual bits of this, but doing
//the whole thing seems fine

void FurSurfaceFunc(Input IN, inout SurfaceOutputStandard o)
{
	//clip on zero length guides
	clip(IN.texcoord.z);

	float4	strandMapSample = tex2D(_StrandShapeMapUND, TRANSFORM_TEX(IN.texcoord.xy, _StrandShapeMapUND));
#ifndef MOBILEFUR
	strandMapSample.r = lerp(strandMapSample.r, SCurve(_PatternCurvePower, strandMapSample.r), _bAdjustPatternCurve);
#endif

	float4	heightMapSample = 1;

#ifdef HEIGHT_MAPS_UND_ON
	heightMapSample = tex2D(_HeightMapUND, TRANSFORM_TEX(IN.texcoord.xy, _HeightMapUND));

#ifndef MOBILEFUR // if not mobile fur
	heightMapSample = lerp(1, heightMapSample, _bHeightMapUND);
	heightMapSample.r = lerp(_StrandLengthMinUND, _StrandLengthMaxUND, heightMapSample.r);
#endif
#endif

	float alpha = NeoFur_Alpha(IN.texcoord.z, strandMapSample.r, heightMapSample.r);

	clip(alpha);

	// find strand color
	float3	finalColor;

#ifdef MOBILEFUR // if mobile fur
	// mobile fur color is only sampled from texture
	finalColor = tex2D(_ColorTipMapUND, TRANSFORM_TEX(IN.texcoord.xy, _ColorTipMapUND));
#else //if not mobile fur
	float4 colorRoot = _ColorRootUND;
	float4 colorTip = _ColorTipUND;

#ifdef COLOR_MAPS_UND_ON
	colorRoot = tex2D(_ColorRootMapUND, TRANSFORM_TEX(IN.texcoord.xy, _ColorRootMapUND));
	colorTip = tex2D(_ColorTipMapUND, TRANSFORM_TEX(IN.texcoord.xy, _ColorTipMapUND));
#endif

	// blend root and tip strand color
	finalColor = lerp(colorRoot.rgb, colorTip.rgb, IN.texcoord.z);

#ifdef COLOR_MAPS_UND_ON
	finalColor *= lerp(_ColorTintRootUND, _ColorTintTipUND, IN.texcoord.z);
#endif

#endif

	// fake lighting on fur strands with AO
	float ao = 1;
	float furNoiseAO = 1;
#ifdef MOBILEFUR
	furNoiseAO = FurNoiseAO(strandMapSample.r, _AOPattern, 1, heightMapSample.r);
#else
	ao = UseAlphaAsAO(strandMapSample.r, _AOValue);
	furNoiseAO = FurNoiseAO(strandMapSample.r, _AOPattern, _AOPatternDarkness, heightMapSample.r);
#endif

	finalColor *= furNoiseAO;

	float fresnel = 1.0 - abs(dot(normalize(IN.viewDir), IN.worldNormal));
	float rimMask = pow(fresnel, _RimContrast);
	finalColor = lerp(finalColor, (rimMask + _RimCenter)*finalColor, _RimBrightness);
	// output
	o.Albedo = finalColor;
	o.Smoothness = _Smoothness;
	o.Metallic = _Metallic;
	o.Occlusion = ao;
	//o.Normal = v.bentWorldNormal;

	//o.Albedo = rimMask;
}
#endif

#endif