// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef VERTEX_FILTER_INCLUDED
#define VERTEX_FILTER_INCLUDED
#include "UnityCG.cginc"
#include "../../../Shaders/NeoFurInput.cginc"
#include "../../../Shaders/NeoFurUtility.cginc"
struct VertexFilterV2F
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
};

VertexFilterV2F VertexFilterVertexShader(appdata_full v)
{
	VertexFilterV2F o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.texcoord;
	return o;
}

#endif
