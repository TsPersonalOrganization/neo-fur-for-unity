Shader "NeoFur/FurSurfaceComplex"
{
	Properties
	{
		//Expose multi_compile_instancing option
		//[Toggle(INSTANCING_ON)] _InstancingOn("Enable GPU Instancing?", Float) = 0

		// 1. UNDERCOAT
		// 1.1 UNDERCOAT COLOR
		[Toggle]
		_bColorMapUND("UND Enable color maps", Float) = 0
		[Toggle]
		_bGradientMapUND ("UND Enable gradient color maps", Float) = 0
		[Toggle]
		_bGradientMapRootToTipUND("UND Color strands with gradient Root-to-Tip", Float) = 0
		_GradientMapUND("UND Gradient Color Map", 2D) = "white" {}
		[Toggle]
		_bColorRootMapUND("UND Use Root Color Map", Float) = 0
		_ColorRootMapUND("UND Root Color Map", 2D) = "white" {}
		[Toggle]
		_bColorTipMapUND("UND Use Tip Color Map", Float) = 0
		_ColorTipMapUND("UND Tip Color Map", 2D) = "white" {}
		[HDR]
		_ColorRootUND("UND Root Strand Color", Color) = (0.0735294 ,0.02796502, 0.003243944, 1)
		[HDR]
		_ColorTipUND("UND Tip Strand Color", Color) = (0.6544117, 0.4639287, 0.25984, 1)
		[HDR]
		_ColorTintRootUND("UND Root Strand Tint Color", Color) = (1, 1, 1, 1)
		[HDR]
		_ColorTintTipUND("UND Tip Strand Tint Color", Color) = (1, 1, 1, 1)
		_HueVariationUND("Hue Variation", Range(0, 1)) = 0
		_ValueVariationUND("Value Variation", Range(0, 1)) = .35
		_ValueVariationMapUND("Value Variation Map", 2D) = "white" {}

		// 1.2 UNDERCOAT SHAPE
		//always show
		_StrandShapeMapUND("UND Texture that controls strand shape for undercoat", 2D) = "white" {}
		_StrandColorIndexMapUND("UND Texture with 2 random strand values for undercoat", 2D) = "gray" {}
		//Only exists so that offset and scale are available.
		_StrandShapeMapOVR("OVR Texture that controls strand shape for undercoat", 2D) = "white" {}

		// 1.3 UNDERCOAT DENSITY
		[Toggle]
		_bDensityUND("UND Enable density control for undercoat", Float) = 0
		[Toggle]
		_bDensityMapUND("UND Control undercoat density via texture", Float) = 0
		//if(bDensityMapUND)
		_DensityMapUND("UND Density map for undercoat", 2D) = "white" {}
		//_DensityMapUVScale handled by Unity already
		//else if(!bDensityMapUND)
		_DensityUND("UND Density of Undercoat strands", Range(0,1)) = 1
		//always show
		_DensityMinUND("UND Density Min UND", Range(0, 1)) = 0
		_DensityMaxUND("UND Density Max UND", Range(0, 1)) = 1
		[Toggle]
		_bOpaqueBaseUND("UND Enable the lowest undercoat layer to be opaque. Would hide skin", Float) = 1
		_BaseLayerHeightThreshold("Base Layer Height Threshold", Range(0, 1)) = 1

		// 1.4 UNDERCOAT HEIGHT
		[Toggle]
		_bHeightMapUND("UND Control height of strands with texture", Float) = 0
		//if(bheightMapUND)
		_HMPDepthUND("UND Depth of height map", Range(0,1)) = 0.0
		_HeightMapUND("UND Height Map for Undercoat", 2D) = "white" {}
		//_HeightMapUVScaleUND handled by Unity already
		//always show
		_StrandLengthMinUND("UND Min length of strands", Range(0,1)) = 0.15
		_StrandLengthMaxUND("UND Max length of strands", Range(0,1)) = 1.0

		// 1.4 UNDERCOAT LIGHTING
		[Toggle]
		_bUseAnimatedDither("UND Enable dithering", Float) = 0
		//if(bDitherAnimated)
		_DitherAmount("UND Amount of dither to blend into alpha", Range(0,1)) = 0.25
		//always show
		_GradientScatterMapUND("UND Gradient Map for light scattering", 2D) = "white" {}
		_RoughnessUND("UND Roughness of undercoat", Range(.1, .9)) = .4
		_SpecularBreakupUND("UND Specular reflections break up", Range(0,1)) = .4

		// 2. OVERCOAT
		[Toggle]
		_bOVR("OVR Enable overcoat", Float) = 0

		// 2.1 OVERCOAT COLOR
		[Toggle]
		_bColorOVR("OVR Enable color for overcoat", Float) = 0
		[Toggle]
		_bColorMapOVR("OVR Enable color maps for overcoat", Float) = 0
		[Toggle]
		_bGradientMapOVR("OVR Enable gradient texture for overcoat strand color", Float) = 0
		_GradientMapOVR("OVR Gradient Color Map", 2D) = "white" {}
		[Toggle]
		_bGradientMapRootToTipOVR("OVR Color strands with gradient Root-to-Tip", Float) = 0
		_ColorRootMapOVR("OVR root color map", 2D) = "white" {}
		_ColorTipMapOVR("OVR tip color map", 2D) = "white" {}
		_ColorRootOVR("OVR Color of OVR roots", Color) = (1, 1, 1, 1)
		_ColorTipOVR("OVR Color of OVR tips", Color) = (1, 1, 1, 1)
		_ColorTintRootOVR("OVR Root Strand Tint Color", Color) = (1, 1, 1, 1)
		_ColorTintTipOVR("OVR Tip Strand Tint Color", Color) = (1, 1, 1, 1)

		// 2.3 OVERCOAT DENSITY
		[Toggle]
		_bDensityOVR("OVR Enable density control for overcoat", Float) = 0
		[Toggle]
		_bDensityMapOVR("OVR Use texture for overcoat density", Float) = 0
		_DensityMapOVR("OVR Density map for overcoat", 2D) = "white" {}
		_DensityOVR("OVR Density of overcoat strands", Range(0, 1)) = 1
		_DensityMinOVR("OVR Min density for overcoat", Range(0, 1)) = 0
		_DensityMaxOVR("OVR Max density for overcoat", Range(0, 1)) = 1

		// 2.4 OVERCOAT HEIGHT
		[Toggle]
		_bHeightMapOVR("OVR Control height of strands with texture", Float) = 0
		//if(bheightMapUND)
		//_HMPDepthOVR("Depth of overcoat height map", Range(0, 1)) = .5
		//_HeightMapOVR("Height Map for Undercoat", 2D) = "white" {}
		_StrandLengthMinOVR("OVR Min length of overcoat strands", Range(0, 1)) = 0.5
		_StrandLengthMaxOVR("OVR Max length of overcoat strands", Range(0, 1)) = 1.0

		// 2.5 OVERCOAT LIGHTING
		_GradientScatterMapOVR("OVR Gradient scatter map for overcoat", 2D) = "white" {}
		_RoughnessOVR("OVR Roughness of overcoat", Range(.1, .9)) = .4
		_ScatterOVR("OVR Scatter Amount", Range(0,1)) = .5
		_SpecularBreakupOVR("OVR Specular reflections break up", Range(0,1)) = 0.35

		// 3. SURFACE VALUES
		_AOValue("AO", Range(0,1)) = 0.75
		_EmissionColor ("Emissive color", Color) = (0,0,0)

		_CullMode("Culling Mode", Float) = 2
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		//LOD 600
		Cull [_CullMode]

		CGPROGRAM

		//Replace FurStandard with your own lighting function if you want
		//to do some kind of special lighting.  Remember that the function
		//name needs to begin with Lighting and should have versions for
		//forward, deferred, and GI similar to ours in NeoFurLighting.cginc
		//See SampleLighting.cginc for examples
		#pragma	surface FurSurf FurStandard vertex:FurVS addshadow fullforwardshadows nolightmap nometa
#if defined(SHADER_API_D3D11)
#pragma target 5.0
#else
#pragma target 3.0
#endif

		// NeoFur shader features
		#pragma shader_feature		NEOFUR_COMPLEX_OVR_OFF			NEOFUR_COMPLEX_OVR_ON
		#pragma shader_feature		NEOFUR_COMPLEX_DENSITY_OFF		NEOFUR_COMPLEX_DENSITY_ON
		#pragma shader_feature		HEIGHT_MAPS_UND_OFF				HEIGHT_MAPS_UND_ON
		#pragma shader_feature		COLOR_MAPS_UND_OFF				COLOR_MAPS_UND_ON

		#pragma multi_compile_instancing

		#define COMPLEXFUR

#include "NeoFurSetupComplex.cginc"
#include "NeoFurVertexShader.cginc"
#include "NeoFurLighting.cginc"

		void FurSurf(Input IN, inout SurfaceOutputNeoFur o)
		{
			//surface function in FurSetup.cginc
			ComplexFurSurfaceFunc(IN, o);
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "Neoglyphic.NeoFur.Editor.NeoMaterialInspector"
}
