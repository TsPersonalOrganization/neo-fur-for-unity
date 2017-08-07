Shader "NeoFur/FurSurface"
{
	Properties
	{
		// 1. FUR
		// 1.1 COLOR
		[Header(COLOR)]
		[HDR]
		_ColorRootUND("Root Strand Color", Color) = (0.0735294 ,0.02796502, 0.003243944, 1)
		[HDR]
		_ColorTipUND("Tip Strand Color", Color) = (0.6544117, 0.4639287, 0.25984, 1)
		[HDR]
		_ColorTintRootUND("Root Strand Tint Color", Color) = (1, 1, 1, 1)
		[HDR]
		_ColorTintTipUND("Tip Strand Tint Color", Color) = (1, 1, 1, 1)
		[Toggle]
		_bColorMapUND("Root Texture Enable", Float)				=0
		_ColorRootMapUND("Root Texture", 2D)						="white" {}
		_ColorTipMapUND("Tip Texture", 2D)							="white" {}

		// 1.2 SHAPE and DENSITY
		[HEADER(SHAPE and DENSITY)]
		_StrandShapeMapUND("Fur Noise Texture", 2D)					="white" {}
		[Toggle]
		_bAdjustPatternCurve("Use scurve correction for strands", Float) = 0
		_PatternCurvePower("Power curve for strand correction", Range(.5, 4)) = 2
			[Toggle]
		_bHeightMapUND("Enable height map", Float) = 0
		_HeightMapUND("Height map for strand growth", 2D) = "white" {}

		// 1.3 HEIGHT
		_StrandLengthMinUND("Strand Length Min", Range(0, 1)) = 0.5
		_StrandLengthMaxUND("Strand Length Max", Range(0, 1)) = 1

		// 2. SURFACE
			// AO
		_AOValue("Overall AO Factor", Range(0, 1)) = 1.0
		_AOPattern("AO factor for light areas in fur pattern", Range(0, 1)) = 0.5
		_AOPatternDarkness("AO factor for dark areas in fur pattern", Range(0, 1)) = 0.5

			// lighting
		_Smoothness("Smoothness", Range(0, 1))						=0.5
		_Metallic("Metallic", Range(0, 1))							=0
		_RimBrightness("RimBrightness", Range(0, 8)) = 3.0
		_RimCenter("RimCenter", Range(0, 1)) = 1.0
		_RimContrast("RimContrast", Range(0, 8)) = 3.0

		_CullMode("Culling Mode", Float) = 2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 600
		Cull [_CullMode]

		CGPROGRAM

		//Replace FurStandard with your own lighting function if you want
		//to do some kind of special lighting.  Remember that the function
		//name needs to begin with Lighting and should have versions for
		//forward, deferred, and GI similar to ours in NeoFurLighting.cginc
		//See SampleLighting.cginc for examples
		#pragma	surface FurSurf Standard vertex:FurVS addshadow nolightmap nometa
#if defined(SHADER_API_D3D11)
#pragma target 5.0
#else
#pragma target 3.0
#endif

		#pragma shader_feature COLOR_MAPS_UND_OFF COLOR_MAPS_UND_ON
		#pragma shader_feature HEIGHT_MAPS_UND_OFF HEIGHT_MAPS_UND_ON

		//support instancing if available
		#pragma multi_compile_instancing

#include "NeoFurSetup.cginc"
#include "NeoFurVertexShader.cginc"
#include "NeoFurLighting.cginc"

		void FurSurf(Input v, inout SurfaceOutputStandard o)
		{
			//surface function in FurSetup.cginc
			FurSurfaceFunc(v, o);
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "Neoglyphic.NeoFur.Editor.NeoMaterialInspector"
}
