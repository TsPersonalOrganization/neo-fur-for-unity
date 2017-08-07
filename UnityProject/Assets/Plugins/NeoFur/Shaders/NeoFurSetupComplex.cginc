#ifndef FUR_SETUP_COMPLEX
#define FUR_SETUP_COMPLEX

#ifndef MOBILEFUR
#ifdef COMPLEXFUR

#include "NeoFurSetup.cginc"

// @summary: Determines clipping alpha value for "complex" fur
// @returns: value used to clip shell pixel
// @author: Wyatt
float NeoFur_AlphaComplex(float texcoord2G, float idMap,	// ids
	float heightInput,										// height
	float densityInput, fixed bBaseLayer)					// density
{
	float densityInverse = 1 - densityInput;

	float densityBasedOnID;

	densityBasedOnID = lerp(0, 1, ceil(idMap - densityInverse));

	float heightMultDensity = heightInput * densityBasedOnID;

	float baseLayerOffset = lerp(0.001, 0, bBaseLayer);

	float alpha = heightMultDensity - texcoord2G - baseLayerOffset;
	return alpha;
}

//Strand Funcs

float GetHeightMapShaping(float4 heightMapSample, float hmpDepth)
{
	float height = lerp(hmpDepth, 1, heightMapSample.r);

	return height;
}

float GetCoatStrands(float4 strandMapSample, float strandLengthMin, float strandLengthMax)
{
	return lerp(strandLengthMin, strandLengthMax, strandMapSample.g) * strandMapSample.r;
}

// Misc funcs

fixed GetBottomLayerMask(float2 texcoord2)
{
	// return texcoord2.x >= .001 ? 0 : 1;
	// can be rewritten to 
	// return .001 > texcoord2.x ? 1 : 0
	// then we can avoid branching with a lerp
	 return lerp(0, 1, ceil(.001 - texcoord2.x));
}

// color funcs

float4 GradientMap_Multi(float grayscaleValToGradientMap, float inputIndex, sampler2D gradientMap, float numGradientsInGradientMap)
{
	float div = 1 / max(ceil(numGradientsInGradientMap), 1);
	float index = ceil(inputIndex);

	float divIndexSum = div * .5 + div * index;

	float2 appendedUV = float2(grayscaleValToGradientMap, divIndexSum);

	float4 gradientSample = tex2D(gradientMap, appendedUV);

	return gradientSample;
}

float3 GetHueShift(float hueShiftPercentage, float3 colorInput)
{
	float3 colorShifted = RotateAboutAxis(normalize(float3(1, 1, 1)), hueShiftPercentage, 0, colorInput);
	float3 colorOutput = colorShifted + colorInput;

	return colorOutput;
}

float3 GetHueVariation(float idMap, float hueVariationInput, float3 colorInput)
{
	float hueMult5 = hueVariationInput * 5;
	float hueLerp = lerp(hueMult5, hueVariationInput, idMap);
	float3 hueShift = GetHueShift(hueLerp, colorInput);

	return lerp(colorInput, hueShift, hueVariationInput);
}

float GetValueVariation(float idMap, float shellRatio, sampler2D valueVariationMap, float valueVariationInput)
{
	float idMapInverse = 1 - idMap;
	//float valueMapSample = GradientMap_Multi(shellRatio, 0, valueVariationMap, 3);

	//return lerp(valueMapSample, idMapInverse, valueVariationInput);
	return lerp(.5, idMapInverse, valueVariationInput);
}

//TODO: implement Blend_Overlay function
float3 Blend_Overlay(float3 baseColor, float3 blendColor)
{
	float3 v111 = float3(1, 1, 1);

	// over .5
	float3 baseColorInvertedMult2 = (v111 - baseColor) * 2;
	float3 blendColorInverted = v111 - blendColor;
	float3 over5Output = v111 - baseColorInvertedMult2 * blendColorInverted;

	//under .5
	float3 baseColorMult2 = 2 * baseColor;
	float3 under5Output = baseColorMult2 * blendColor;

	//split channels and compare and recombine
	float3 output;

	// if baseColor.r > .5, meaning baseColor.r - .5 is (+), ceil of that value will be 1
	// if baseColor.r <= .5, meaning baseColor.r -,5 is 0 or (-), ceil of that value will be 0
	output.r = lerp(under5Output.r, over5Output.r, ceil(baseColor.r - .5));
	output.g = lerp(under5Output.g, over5Output.g, ceil(baseColor.g - .5));
	output.b = lerp(under5Output.b, over5Output.b, ceil(baseColor.b - .5));

	return output;
}

float3 GetStrandColor(float texcoord2G, float4 strandMapSample,
	float4 colorRootMapSample, float4 colorTipMapSample,					//color map values
	fixed bGradientMap, fixed bGradientRootToTip, sampler2D gradientMap,						//gradient map values
	float3 rootColor, float3 tipColor)														//color values
{
	//color map
	float3 colorMapSampleBlend = lerp(colorRootMapSample, colorTipMapSample, texcoord2G);

	//gradient mapping
	float grayscaleValToGradientMap = lerp(strandMapSample.g, texcoord2G, bGradientRootToTip);
	float4 gradientColorRGBA = GradientMap_Multi(grayscaleValToGradientMap, 0, gradientMap, 1);

	float3 colorMapColor = lerp(colorMapSampleBlend, gradientColorRGBA.rgb, bGradientMap);

	//color values
	float3 colorValBlend = lerp(rootColor, tipColor, texcoord2G);

	float3 colorBlend = colorValBlend*colorMapColor;

	return colorBlend;
}

//Lighting Funcs

float GetRoughness(float roughnessUND, float roughnessOVR, float alpha, fixed bOVR)
{
	return lerp(roughnessUND, lerp(roughnessUND, roughnessOVR, alpha), bOVR);
}

float GetPerStrandScatterVariance(float idMap, sampler2D gradientScatterMap,
	fixed bOVR, fixed scatterOVRInput, float alphaOVR, //OVR
	float bottomLayerMask)
{
	float scatterMapSampleR = GradientMap_Multi(idMap, 0, gradientScatterMap, 3).r;

	float scatterOVROutput = lerp(0, scatterOVRInput, bOVR);

	scatterOVROutput = lerp(scatterMapSampleR, scatterOVROutput, alphaOVR);
	scatterOVROutput = lerp(scatterOVROutput, scatterOVRInput, bottomLayerMask);

	return scatterOVROutput;
}

float3 GetPerStrandTangentVariance(float4 normalMapSample, float specularBreakup)
{
	float3 normalVariance = lerp(float3(0, 0, 0), float3(.25, 0, 0), specularBreakup);

	return normalMapSample + normalVariance;
}

void ComplexFurSurfaceFunc(Input IN, inout SurfaceOutputNeoFur o)
{
	// clip 0 and negative length fur guide
	clip(IN.texcoord.z - lerp(.001, 0, ceil(IN.texcoord.z)));
	//clip(IN.texcoord.z);
	// STRAND VALUES
	// STRAND VALUES
	// STRAND VALUES

	// get UND strand values
	float2 strandUNDUV = TRANSFORM_TEX(IN.texcoord.xy, _StrandShapeMapUND);
	float4 strandMapSampleUND = tex2D(_StrandShapeMapUND, strandUNDUV);
	strandMapSampleUND.yz = tex2D(_StrandColorIndexMapUND, strandUNDUV).yz;
	float strandUND = GetCoatStrands(strandMapSampleUND, _StrandLengthMinUND * 2, _StrandLengthMaxUND * 2);

#ifdef NEOFUR_COMPLEX_OVR_ON
	// get OVR strand values
	float2 strandOVRUV = TRANSFORM_TEX(IN.texcoord.xy, _StrandShapeMapOVR);
	float4 strandMapSampleOVR = tex2D(_StrandShapeMapUND, strandOVRUV);
	strandMapSampleOVR.yz = tex2D(_StrandColorIndexMapUND, strandOVRUV).yz;
	float strandOVR = GetCoatStrands(strandMapSampleOVR, _StrandLengthMinOVR * 2, _StrandLengthMaxOVR * 2);
	
	strandOVR = lerp(0, strandOVR, _bOVR);
#endif
	// HEIGHT VALUES
	// HEIGHT VALUES
	// HEIGHT VALUES

	// get UND height values
	float scaledHeightUND = strandUND;
#ifdef HEIGHT_MAPS_UND_ON
	float4 heightMapSampleUND = tex2D(_HeightMapUND, TRANSFORM_TEX(IN.texcoord.xy, _HeightMapUND));
	float heightMapShapingUND = GetHeightMapShaping(heightMapSampleUND, _HMPDepthUND);
	heightMapShapingUND = lerp(1, heightMapShapingUND, _bHeightMapUND);
	scaledHeightUND *= heightMapShapingUND;
#endif

#ifdef NEOFUR_COMPLEX_OVR_ON
	//get OVR height values
#ifdef HEIGHT_MAPS_UND_ON
	float heightMapShapingOVR = lerp(1, heightMapShapingUND, _bHeightMapOVR);
#else
	float heightMapShapingOVR = 1;
#endif
	heightMapShapingOVR = lerp(1, heightMapShapingOVR, _bOVR);
	float scaledHeightOVR = heightMapShapingOVR * strandOVR;
	scaledHeightOVR = lerp(0, scaledHeightOVR, _bOVR);
#endif

	// DENSITY VALUES
	// DENSITY VALUES
	// DENSITY VALUES

#ifdef NEOFUR_COMPLEX_DENSITY_ON
	// get UND density values
	float4 densityMapSampleUND = tex2D(_DensityMapUND, TRANSFORM_TEX(IN.texcoord.xy, _DensityMapUND));
	float densityUND = _bDensityMapUND > 0.5 ? lerp(_DensityMinUND, _DensityMaxUND, densityMapSampleUND.r) : _DensityUND;
#else
	float densityUND = 1;
#endif

#ifdef NEOFUR_COMPLEX_OVR_ON
	// get OVR density values
	float4 densityMapSampleOVR = tex2D(_DensityMapOVR, TRANSFORM_TEX(IN.texcoord.xy, _DensityMapOVR));
	float densityOVR = _bDensityMapOVR > 0.5 ? lerp(_DensityMinOVR, _DensityMaxOVR, densityMapSampleOVR.r) : _DensityOVR;
	densityOVR = lerp(0, lerp(1, densityOVR, _bDensityOVR), _bOVR);
#endif

	// APLHA VALUES
	// APLHA VALUES
	// APLHA VALUES

	// get the UND alpha values
	float alphaUND = NeoFur_AlphaComplex(IN.texcoord.z, strandMapSampleUND.g,
										 scaledHeightUND, densityUND, _bOpaqueBaseUND);

	float alphaMask = alphaUND;

	fixed bOVRStrand = 0;
#ifdef NEOFUR_COMPLEX_OVR_ON
	// get the OVR alpha values
	float alphaOVR = NeoFur_AlphaComplex(IN.texcoord.z, strandMapSampleOVR.g,
										 scaledHeightOVR, densityOVR, false);

	// check if this strand is an OVR strand
	// do this by getting ceiling of base shell alpha
	bOVRStrand = ceil(NeoFur_AlphaComplex(0, strandMapSampleOVR.g,
										 scaledHeightOVR, densityOVR, false));
	
	
	//bOVRStrand = lerp(bOVRStrand, 0, bBaseLayer);
	//bOVRStrand = lerp(0, bOVRStrand, _bOVR);

	bOVRStrand = ceil(alphaOVR);
	alphaMask = lerp(alphaMask, alphaOVR, bOVRStrand);
#endif

	float baseLayerValue = 1;
#ifdef HEIGHT_MAPS_UND_ON
	baseLayerValue = lerp(alphaMask-(1.0-heightMapShapingUND), 1, _BaseLayerHeightThreshold);
#endif
	//Opaque base layer.
	alphaMask = lerp(alphaMask, baseLayerValue, saturate(_bOpaqueBaseUND * (IN.texcoord.z * _NeoFur_ShellCount <= 1)));

	//CLIP PIXEL
	//CLIP PIXEL
	//CLIP PIXEL

	//perform optional dither here
#if !defined(UNITY_PASS_SHADOWCASTER)
	float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
	float ditherPattern = GetDitherPattern(screenUV);
	alphaMask = alphaMask+ditherPattern*_DitherAmount*_bUseAnimatedDither;
#endif
	// clip the pixel if clipValue negative
	clip(alphaMask);

	// COLOR VALUES
	// COLOR VALUES
	// COLOR VALUES
#ifdef COLOR_MAPS_UND_ON
	// get UND color samples
	float4 colorRootMapSampleUND = tex2D(_ColorRootMapUND, TRANSFORM_TEX(IN.texcoord.xy, _ColorRootMapUND));
	float4 colorTipMapSampleUND = tex2D(_ColorTipMapUND, TRANSFORM_TEX(IN.texcoord.xy, _ColorTipMapUND));

	float3 strandColorUND = GetStrandColor(IN.texcoord.z, strandMapSampleUND,
		colorRootMapSampleUND, colorTipMapSampleUND,
		_bGradientMapUND, _bGradientMapRootToTipUND, _GradientMapUND,
		_ColorTintRootUND, _ColorTintTipUND);
#else
	float3 strandColorUND = lerp(_ColorRootUND, _ColorTipUND, IN.texcoord.z);
#endif

	// get flattened bottom layer mask
	float bottomLayerMask = GetBottomLayerMask(IN.texcoord.z);

	// value shift
	float valueVariation = GetValueVariation(strandMapSampleUND.g, IN.texcoord.z,
		_ValueVariationMapUND, _ValueVariationUND);
	valueVariation = lerp(valueVariation, .5, bottomLayerMask);

	// hue shift
	float3 hueBlend = GetHueVariation(strandMapSampleUND.g, _HueVariationUND, strandColorUND);

	float3 colorUND = Blend_Overlay(hueBlend, valueVariation);

	float3 finalColor = colorUND;
#ifdef NEOFUR_COMPLEX_OVR_ON
	// get OVR color
	float4 colorRootMapSampleOVR = tex2D(_ColorRootMapOVR, TRANSFORM_TEX(IN.texcoord.xy, _ColorRootMapOVR));
	float4 colorTipMapSampleOVR = tex2D(_ColorTipMapOVR, TRANSFORM_TEX(IN.texcoord.xy, _ColorTipMapOVR));
	float3 strandColorOVR = GetStrandColor(IN.texcoord.z, strandMapSampleOVR,
		colorRootMapSampleOVR, colorTipMapSampleOVR,
		_bGradientMapOVR*_bColorMapOVR, _bGradientMapRootToTipOVR, _GradientMapOVR,
		_bColorMapOVR > 0.5 ? _ColorTintRootOVR : _ColorRootOVR, _bColorMapOVR > 0.5 ? _ColorTintTipOVR : _ColorTipOVR);

	// COMBINE UND + OVR COLORS + PER STRAND LIGHTING
	// COMBINE UND + OVR COLORS + PER STRAND LIGHTING
	// COMBINE UND + OVR COLORS + PER STRAND LIGHTING

	finalColor = lerp(finalColor, strandColorOVR, bOVRStrand*_bColorOVR);
#endif

	// get lighting values
	float scatterVariation = GetPerStrandScatterVariance(strandMapSampleUND.g, _GradientScatterMapUND,
		_bOVR, _ScatterOVR, bOVRStrand, bottomLayerMask);

	float roughness = GetRoughness(_RoughnessUND, _RoughnessOVR, bOVRStrand, _bOVR);

	//NORMALS
	//NORMALS
	//NORMALS

	float2 specularBreakup = (strandMapSampleUND.gb * 2 - 1) * _SpecularBreakupUND;
#ifdef NEOFUR_COMPLEX_OVR_ON
	specularBreakup = lerp(specularBreakup, (strandMapSampleOVR.gb * 2 - 1) * _SpecularBreakupOVR, bOVRStrand);
#endif
	//This isnt 100% correct. worldBreakupVector is based on vertex normal tangents instead of
	//bent normal tangents.
	float3 worldBreakupVector = WorldNormalVector(IN, float3(specularBreakup, 0));
	IN.bentWorldNormal += worldBreakupVector;
	IN.bentWorldNormal = normalize(IN.bentWorldNormal);
	o.Normal = float3(specularBreakup, 1);

	//AMBIENT OCCLUSION
	//AMBIENT OCCLUSION
	//AMBIENT OCCLUSION

	//// AO pseudo
	//// AO = _AOValue * mixture(HeightAO, StrandLengthAO, DensityAO)

	float finalAO = scaledHeightUND;
#ifdef NEOFUR_COMPLEX_OVR_ON
	finalAO = lerp(finalAO, scaledHeightOVR, bOVRStrand);
#endif
	// OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT
	// OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT
	// OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT OUTPUT

	//set color
	o.Albedo = finalColor;
	//set specular and smoothness
	//o.Specular = float3(0.5, scatterVariation, 0);
	o.Scatter = scatterVariation;
	o.Smoothness = roughness;
	//o.Smoothness = 0;

	// apply occlusion
	o.Occlusion = finalAO;

	//channel available in Emission.a?
	o.Emission = _EmissionColor;
	o.BentNormal = IN.bentWorldNormal;
	// +strandNormal; apply per-strand tangent variance
}

#endif 
// ifdef		COMPLEXFUR
#endif
// ifndef	MOBILEFUR
#endif
// ifndef	FUR_SETUP_COMPLEX