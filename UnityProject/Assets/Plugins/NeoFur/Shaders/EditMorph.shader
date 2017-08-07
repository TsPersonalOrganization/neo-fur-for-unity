// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NeoFur/EditMorph"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex		MorphVS
			#pragma fragment	MorphPS
			
			#include "UnityCG.cginc"

			struct VSInput
			{
				float3	Position	: POSITION;
			};

			struct PSInput
			{
				float4	Position	: SV_POSITION;
			};

			PSInput MorphVS(VSInput v)
			{
				PSInput	o;

				o.Position = UnityObjectToClipPos(float4(v.Position, 1));

				return	o;
			}

			float4	MorphPS(PSInput i) : SV_Target
			{
				return	float4(1, 0, 0, 0.5);
			}
			ENDCG
		}
	}
}
