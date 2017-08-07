Shader "NeoFur/FurSurfaceMobile" {
	Properties
	{
		// 1. FUR
		// 1.1 COLOR
		[Header(COLOR)]
		_ColorTipMapUND("Tip Texture", 2D)							= "white" {}

		// 1.2 SHAPE and DENSITY
		[HEADER(SHAPE and DENSITY)]
		_StrandShapeMapUND("Fur Noise Texture", 2D)					= "white" {}

		// 1.3 HEIGHT
		_HeightMapUND("Height map for undercoat", 2D) = "white" {}
		_StrandLengthMinUND("Strand Length Min", Range(0, 1))		= 0.5
		_StrandLengthMaxUND("Strand Length Max", Range(0, 1))		= 1
		_StrandAlphaOffset("Offset of base layer of fur", Range(-1,1)) = -.03

		// 2. SURFACE
		_Smoothness("Smoothness", Range(0, 1))						= 0.5
		_Metallic("Metallic", Range(0, 1))							= 0
		_AOPattern("AO based on fur pattern", Range(0,1)) = .5
		_RimBrightness("RimBrightness", Range(0, 8)) = 3.0
		_RimCenter("RimCenter", Range(0, 1)) = 1.0
		_RimContrast("RimContrast", Range(0, 8)) = 3.0

		_CullMode("Culling Mode", Float) = 2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Cull [_CullMode]

		LOD 400

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

		#pragma shader_feature HEIGHT_MAPS_UND_OFF HEIGHT_MAPS_UND_ON

		//support instancing if available
		#pragma multi_compile_instancing

		//drop a few features for mobile
		#define MOBILEFUR

#include "NeoFurSetup.cginc"
#include "NeoFurVertexShader.cginc"
#include "NeoFurLighting.cginc"

		void FurSurf(Input v, inout SurfaceOutputStandard o)
		{
			FurSurfaceFunc(v, o);
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "Neoglyphic.NeoFur.Editor.NeoMaterialInspector"
}
