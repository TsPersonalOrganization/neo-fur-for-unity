Shader "Hidden/NeoFur/VertexFilter/Bones"
{
	Properties
	{

	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		CGINCLUDE
		#define COMPUTE_FUNCTION ComputeFunction
		#include "VertexFilter.cginc"

		uniform float		_NumBindPoses;
		uniform float		_BlendWeight;
		uniform sampler2D	_BlendPosOffsetTexture;
		uniform sampler2D	_BlendNormOffsetTexture;
		uniform sampler2D	_BlendTanOffsetTexture;
		uniform sampler2D	_NeoFur_BoneMatrixTexture;
		uniform sampler2D	_NeoFur_BoneWeightTexture;
		uniform sampler2D	_NeoFur_BoneIndexTexture;

		float4x4 _identityMatrix = float4x4(1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1);

		struct BoneFragmentOutput
		{
			float4 position : SV_Target0;
			float4 normal : SV_Target1;
			float4 tangent : SV_Target2;
		};
		ENDCG

		Pass // 0
		{
			CGPROGRAM
			#pragma vertex VertexFilterVertexShader
			#pragma fragment Frag

			BoneFragmentOutput Frag(VertexFilterV2F vertex)
			{
				BoneFragmentOutput o = (BoneFragmentOutput)0;

				float3 localPosition = tex2D(_NeoFur_PositionTexture, vertex.uv).xyz;
				float3 localNormal = tex2D(_NeoFur_NormalTexture, vertex.uv).xyz;
				float3 localTangent = tex2D(_NeoFur_TangentTexture, vertex.uv).xyz;

				float3 localPositionOffset = tex2D(_BlendPosOffsetTexture, vertex.uv).xyz;
				float3 localNormalOffset = tex2D(_BlendNormOffsetTexture, vertex.uv).xyz;
				float3 localTangentOffset = tex2D(_BlendTanOffsetTexture, vertex.uv).xyz;

				o.position = float4(localPosition + localPositionOffset * _BlendWeight, 1);
				o.normal = float4(localNormal + localNormalOffset * _BlendWeight, 1);
				o.tangent = float4(normalize(localTangent + localTangentOffset * _BlendWeight), 1);

				return o;
			}

			ENDCG
		}

		Pass // 1
		{
			CGPROGRAM
			#pragma vertex VertexFilterVertexShader
			#pragma fragment Frag
			#pragma target 3.0
			
			float4x4 GetBoneMatrix(float index)
			{
				// use built-in projection params instead of NumBindPoses
				index = (index + .5) / _NumBindPoses;

				float4 m0 = tex2D(_NeoFur_BoneMatrixTexture, float2(0.01, index));
				float4 m1 = tex2D(_NeoFur_BoneMatrixTexture, float2(.26, index));
				float4 m2 = tex2D(_NeoFur_BoneMatrixTexture, float2(.51, index));
				float4 m3 = tex2D(_NeoFur_BoneMatrixTexture, float2(.76, index));

				return float4x4(m0, m1, m2, m3);
			}

			float4x4 GetWeightedBoneMatrix(float2 uv)
			{
				float4 boneIndices = tex2D(_NeoFur_BoneIndexTexture, uv);
				float4 boneWeights = tex2D(_NeoFur_BoneWeightTexture, uv);

				float4x4 bone0 = GetBoneMatrix(boneIndices.r);
				float4x4 bone1 = GetBoneMatrix(boneIndices.g);
				float4x4 bone2 = GetBoneMatrix(boneIndices.b);
				float4x4 bone3 = GetBoneMatrix(boneIndices.a);

				return	boneWeights.x * bone0 +
						boneWeights.y * bone1 +
						boneWeights.z * bone2 +
						boneWeights.w * bone3;
			}

			BoneFragmentOutput Frag(VertexFilterV2F vertex)
			{
				float3 localPosition = tex2D(_NeoFur_PositionTexture, vertex.uv).xyz;
				float3 localNormal = tex2D(_NeoFur_NormalTexture, vertex.uv).xyz;
				float3 localTangent = tex2D(_NeoFur_TangentTexture, vertex.uv).xyz;

				BoneFragmentOutput output;

				float4x4 weightedBoneMatrix = GetWeightedBoneMatrix(vertex.uv);

				output.position = float4(mul(weightedBoneMatrix, float4(localPosition, 1)).xyz, 1);
				output.normal = float4(mul(weightedBoneMatrix, float4(localNormal, 0)).xyz, 1);
				output.tangent = float4(mul(weightedBoneMatrix, float4(localTangent, 0)).xyz, 1);

				return output;
			}
			ENDCG
		}
	}
}
