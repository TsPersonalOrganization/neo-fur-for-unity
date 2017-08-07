#ifndef NEOFUR_VERTEX_SHADER_INCLUDED
#define NEOFUR_VERTEX_SHADER_INCLUDED

#include "NeoFurUtility.cginc"
sampler2D _NeoFur_PhysicsPositionTexture;
sampler2D _NeoFur_PhysicsVelocityTexture;
sampler2D _NeoFur_PhysicsGuideTexture;

void FurVS(inout InputVS v, out Input o)
{
	float4 vertexSampleUV = float4(v.texcoord1.xy, 0, 0);

	float4 positionSample = tex2Dlod(_NeoFur_PositionTexture, vertexSampleUV);
	float4 normalSample = tex2Dlod(_NeoFur_NormalTexture, vertexSampleUV);
	float4 tangentSample = tex2Dlod(_NeoFur_TangentTexture, vertexSampleUV);

	v.vertex.xyz = positionSample.xyz;
	v.normal = normalSample.xyz;
	v.tangent.xyz = tangentSample.xyz;

	v.vertex.xyz += v.normal*_NeoFur_ShellOffset;

	float3 localBinormal = cross(v.normal, v.tangent.xyz);
	float3 guideVector = FromTangentSpace(tex2Dlod(_NeoFur_PhysicsGuideTexture, vertexSampleUV).xyz, v.normal, localBinormal, v.tangent.xyz);

	float3 worldCPOffset = 0;
#ifdef SHADER_API_D3D9
	worldCPOffset = float3(positionSample.a, normalSample.a, tangentSample.a);
#else
	worldCPOffset = tex2Dlod(_NeoFur_PhysicsPositionTexture, vertexSampleUV).xyz;
#endif
	
	float3 localCPPosition = v.vertex.xyz+mul(unity_WorldToObject, float4(worldCPOffset, 0)).xyz;

#ifdef INSTANCING_ON
	DoFurMath(unity_InstanceID, localCPPosition, guideVector, v, o);
#else
	DoFurMath(_NeoFur_CurShell, localCPPosition, guideVector, v, o);
#endif
}
#endif
