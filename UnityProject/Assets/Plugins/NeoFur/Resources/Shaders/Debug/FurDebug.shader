// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/NeoFur/Debug/FurDebug"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100
		Cull Off
		//ZTest Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
#pragma vertex Vertex
#pragma fragment Fragment
#pragma target 3.0

#include "../VertexFilters/VertexFilter.cginc"

			sampler2D _NeoFur_PhysicsPositionTexture;
			sampler2D _NeoFur_PhysicsGuideTexture;

			struct VertToFrag
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : TEXCOORD1;
			};
			
			VertToFrag Vertex(appdata_full v)
			{
				VertToFrag output;

				float4 vertexSampleUV = float4(v.texcoord1.xy, 0, 0);

				v.vertex.xyz = tex2Dlod(_NeoFur_PositionTexture, vertexSampleUV).xyz;
				v.normal = tex2Dlod(_NeoFur_NormalTexture, vertexSampleUV).xyz;
				v.tangent.xyz = tex2Dlod(_NeoFur_TangentTexture, vertexSampleUV).xyz;

				float3 localBinormal = cross(v.normal, v.tangent.xyz);
				float3 guideVector = FromTangentSpace(tex2Dlod(_NeoFur_PhysicsGuideTexture, vertexSampleUV).xyz, v.normal, localBinormal, v.tangent.xyz);
				float3 localCPPosition = v.vertex.xyz+mul(unity_WorldToObject, float4(tex2Dlod(_NeoFur_PhysicsPositionTexture, vertexSampleUV).xyz, 0)).xyz;

				float3 targetVector = guideVector*_NeoFur_ShellDistance;

				output.color = float4(1, 1, 1, 0.25);
				if (v.texcoord.x < 2)
				{
					float3 normalToCP = normalize(mul(unity_ObjectToWorld, float4(localCPPosition-v.vertex.xyz, 0)).xyz);
					output.color.a = 1.0f;
					output.color.rgb = normalToCP*0.5+0.5;
				}

				if (v.texcoord.x == 0)
				{
					//v.vertex.xyz += targetVector;
				}
				if (v.texcoord.x == 1)
				{
					v.vertex.xyz = localCPPosition;
				}
				else if (v.texcoord.x == 3)
				{
					v.vertex.xyz += targetVector;
				}

				output.vertex = UnityObjectToClipPos(v.vertex);
				/*
				float3 screenNormal = mul(UNITY_MATRIX_MVP, float4(v.normal, 0));
				if (dot(screenNormal, float3(0, 0, -1)) < 0)
				{
					output.color.a = 0;
				}
				*/
				output.uv = v.texcoord;
				return output;
			}
			
			float4 Fragment(VertToFrag vertex) : SV_Target
			{
				return vertex.color;
			}
			ENDCG
		}
	}
}
