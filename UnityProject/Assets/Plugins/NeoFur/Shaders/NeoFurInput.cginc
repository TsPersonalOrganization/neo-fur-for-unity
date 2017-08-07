// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

#ifndef NEO_FUR_INPUT_INCLUDED
#define NEO_FUR_INPUT_INCLUDED

//This file should contain all input shader properties so that when other files are obfuscated we
//can verify that all shader property identifiers have not been obfuscated (because a compiler
//error would occur).

//these must be named in the usual unity way
struct InputVS
{
	float4	vertex				: POSITION;
	float3	normal				: NORMAL;
	float4	tangent				: TANGENT;
	float4	texcoord			: TEXCOORD0;	//standard texture uvs
	float4	texcoord1			: TEXCOORD1;	//for unity's lightmap stuff
	float4	texcoord2			: TEXCOORD2;	//for unity's lightmap stuff
//#if defined(SHADER_API_D3D11)
//	uint	vID					: SV_VertexID;	//for indexing
//#endif
#ifdef INSTANCING_ON
	UNITY_VERTEX_INPUT_INSTANCE_ID
#endif
};

struct SurfaceOutputNeoFur
{
	fixed3 Albedo;
	fixed3 Normal;
	fixed3 BentNormal;
	half3 Emission;
	half Smoothness;
	half Scatter;
	half Occlusion;
	//Not used but requred by Unity.
	fixed Alpha;
};

#ifndef INTERNAL_DATA
#define INTERNAL_DATA
#endif

//this MUST be named Input
//if it is named anything else expect completely
//incomprehensible error messages at line numbers
//beyond the end of your file, plus hours of torment
//deleting whole sections trying to isolate the error
struct Input
{
	float4 texcoord;
	float3 viewDir;
	float4 screenPos;
	float3 bentWorldNormal;
	//Surface shader code generation does something stupid if worldNormal isnt here.
	float3 worldNormal;
	INTERNAL_DATA
		//	float3	tanVec;
		//	float3	biTangent;
};

//for morphs
struct BlendVertex
{
	float3	Position;
	float3	Normal;
	float3	Tangent;
};

struct ControlPoint
{
	float3	Position;
	float3	Velocity;
};

struct WeightGuide
{
	int4	BoneIdx;
	float4	BoneWeights;
	float3	GuideVec;
};

float _NeoFur_DeltaTime;
sampler2D _NeoFur_PositionTexture;
sampler2D _NeoFur_NormalTexture;
sampler2D _NeoFur_TangentTexture;
sampler2D _NeoFur_PreviousPositionTexture;
float4x4 _NeoFur_LocalToWorldMatrix;
float4x4 _NeoFur_PreviousLocalToWorldMatrix;
float4x4 _NeoFur_WorldToLocalMatrix;

//shell related stuff
uniform int		_NeoFur_ShellCount;
uniform int		_NeoFur_TotalShellCount;
uniform float	_NeoFur_CurShell;		//should be an int, but no matpropblock setint
uniform float	_NeoFur_ShellDistance;
uniform float	_NeoFur_ShellFade;
uniform half	_NeoFur_BendExponent;
uniform half	_NeoFur_VisibleLengthScale;
uniform float _NeoFur_NormalDirectionBlend;
uniform float _NeoFur_ShellOffset;
uniform float _NeoFur_JitterFrameCount;

//INSPECTOR-EXPOSED MATERIAL PROPERTIES

// 1. UNDERCOAT UNDERCOAT UNDERCOAT
// 1. UNDERCOAT UNDERCOAT UNDERCOAT
// 1. UNDERCOAT UNDERCOAT UNDERCOAT

// 1.1 UND COLOR
uniform fixed		_bColorMapUND;
uniform fixed		_bGradientMapUND;
uniform fixed		_bGradientMapRootToTipUND;
uniform sampler2D	_GradientMapUND;
uniform float4		_GradientMapUND_ST;
uniform sampler2D	_ColorRootMapUND;
uniform float4		_ColorRootMapUND_ST;
uniform sampler2D	_ColorTipMapUND;
uniform float4		_ColorTipMapUND_ST;
uniform float4		_ColorRootUND;
uniform float4		_ColorTipUND;
uniform float4		_ColorTintRootUND;
uniform float4		_ColorTintTipUND;
uniform float		_HueVariationUND;
uniform float		_ValueVariationUND;
uniform sampler2D	_ValueVariationMapUND;

// 1.2 UND SHAPE + DENSITY
uniform fixed		_bAdjustPatternCurve;
uniform float		_PatternCurvePower;
uniform sampler2D	_StrandShapeMapUND;
uniform sampler2D	_StrandColorIndexMapUND;
uniform float4		_StrandShapeMapUND_ST;
uniform float4		_StrandShapeMapOVR_ST;
uniform fixed		_bDensityUND;
uniform fixed		_bDensityMapUND;
uniform sampler2D	_DensityMapUND;
uniform float4		_DensityMapUND_ST;
uniform float		_DensityUND;
uniform float		_DensityMinUND;
uniform float		_DensityMaxUND;
uniform fixed		_bOpaqueBaseUND;
uniform float _BaseLayerHeightThreshold;
// 1.3 UND HEIGHT
uniform fixed		_bHeightMapUND;
uniform float		_HMPDepthUND;
uniform sampler2D	_HeightMapUND;
uniform float4		_HeightMapUND_ST;
uniform float		_StrandLengthMinUND;
uniform float		_StrandLengthMaxUND;
#ifdef MOBILEFUR
uniform float		_StrandAlphaOffset;
#endif

// 1.4 UND LIGHTING
uniform fixed		_bUseAnimatedDither;
uniform float		_DitherAmount;
uniform fixed		_bUseOcclusionMap;
uniform sampler2D	_GradientScatterMapUND;
uniform float4		_GradientScatterMapUND_ST;
uniform float		_RoughnessUND;
uniform float		_SpecularBreakupUND;


// 2. OVERCOAT OVERCOAT OVERCOAT
// 2. OVERCOAT OVERCOAT OVERCOAT
// 2. OVERCOAT OVERCOAT OVERCOAT
uniform fixed		_bOVR;

// 2.1 OVR COLOR
uniform fixed		_bColorOVR;
uniform fixed		_bColorMapOVR;
uniform fixed		_bGradientMapOVR;
uniform fixed		_bGradientMapRootToTipOVR;
uniform sampler2D	_GradientMapOVR;
uniform float4		_GradientMapOVR_ST;
uniform sampler2D	_ColorRootMapOVR;
uniform float4		_ColorRootMapOVR_ST;
uniform sampler2D	_ColorTipMapOVR;
uniform float4		_ColorTipMapOVR_ST;
uniform float4		_ColorRootOVR;
uniform float4		_ColorTipOVR;
uniform float4		_ColorTintRootOVR;
uniform float4		_ColorTintTipOVR;

// 2.3 OVR DENSITY
uniform fixed		_bDensityOVR;
uniform fixed		_bDensityMapOVR;
uniform sampler2D	_DensityMapOVR;
uniform float4		_DensityMapOVR_ST;
uniform float		_DensityOVR;
uniform float		_DensityMinOVR;
uniform float		_DensityMaxOVR;

// 2.4 OVR HEIGHT
uniform fixed		_bHeightMapOVR;
uniform float		_HMPDepthOVR;
uniform sampler2D	_HeightMapOVR;
uniform float4		_HeightMapOVR_ST;
uniform float		_StrandLengthMinOVR;
uniform float		_StrandLengthMaxOVR;

// 2.5 OVR LIGHTING
uniform sampler2D	_GradientScatterMapOVR;
uniform float4		_GradientScatterMapOVR_ST;
uniform float		_RoughnessOVR;
uniform float		_ScatterOVR;
uniform float		_SpecularBreakupOVR;

// 3. SURFACE SURFACE SURFACE
// 3. SURFACE SURFACE SURFACE
// 3. SURFACE SURFACE SURFACE
uniform half		_AOValue;
#ifndef COMPLEXFUR
uniform half		_AOPattern;
uniform half		_AOPatternDarkness;
#endif
uniform half		_Metallic;
uniform half		_Smoothness;
uniform float3		_EmissionColor;
uniform float		_RimBrightness;
uniform float		_RimCenter;
uniform float		_RimContrast;

#endif
