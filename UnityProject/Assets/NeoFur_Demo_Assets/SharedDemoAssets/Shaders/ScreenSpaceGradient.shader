Shader "Custom/ScreenSpaceGradient" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_GradientMap("Gradient Map", 2D) = "white" {}
		_GradientFactor("Gradient Factor", Range(0,1)) = .25
		[Toggle]
		_bInvertGradient ("Invert Gradient?", Float) = 0
		_NoiseAmount("Amount of noise for gradient smoothing", Range(0,1)) = .1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
#include "UnityPBSLighting.cginc"
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Unlit

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input
		{
			float2 texcoord;
			float4 screenPos;
		};

		sampler2D _GradientMap;
		float4 _GradientMap_ST;
		sampler2D _NoiseMap;
		float4 _NoiseMap_ST;
		float _GradientFactor;
		float _NoiseAmount;
		fixed4 _Color;
		fixed _bInvertGradient;

		float getNoise(float2 uv)
		{
			return frac(sin(dot(uv, float2(.1234124123877, 9.123471234799817))) * 7261.7172614);
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float2 uv0 = IN.screenPos.xy / IN.screenPos.w;

			float2 uv = uv0 * _ScreenParams;

			float distToMiddle = distance(_ScreenParams / 2, uv);
			
			float grayscale = distToMiddle / _ScreenParams.x;

			grayscale = lerp(grayscale, 1 - grayscale, _bInvertGradient);

			grayscale = pow(grayscale, _GradientFactor);

			grayscale = saturate(grayscale);

			float2 sampleUV = float2(grayscale, 0);

			float4 gradSample = tex2D(_GradientMap, TRANSFORM_TEX(sampleUV, _GradientMap));

			float noise = getNoise(uv);

			o.Albedo = _Color * (gradSample.rgb + noise * _NoiseAmount);
		}

		half4 LightingUnlit(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
		{
			return half4(s.Albedo, 1);
		}

		half4 LightingUnlit_Deferred(SurfaceOutputStandard s, half3 viewDir, UnityGI gi,
			out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal)
		{
			outDiffuseOcclusion = 0;
			outSpecSmoothness = 0;
			outNormal = 0;
			return half4(s.Albedo, 1);
		}


		void LightingUnlit_GI(
			SurfaceOutputStandard s,
			UnityGIInput data,
			inout UnityGI gi)
		{
			UNITY_GI(gi, s, data);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
