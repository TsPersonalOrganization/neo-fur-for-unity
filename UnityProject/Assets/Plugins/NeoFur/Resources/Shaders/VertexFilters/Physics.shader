Shader "Hidden/NeoFur/VertexFilter/Physics"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Cull Off
		ZTest Off
		ZWrite Off

		CGINCLUDE
#pragma vertex VertexFilterVertexShader
#pragma fragment Frag
#pragma target 3.0
#include "VertexFilter.cginc"

		sampler2D _NeoFur_PhysicsPositionTexture;
		sampler2D _NeoFur_PhysicsVelocityTexture;
		sampler2D _NeoFur_PhysicsGuideTexture;
		ENDCG

		Pass
		{
			Name "Wind"
			Blend One One
			
			CGPROGRAM
			float3 _NeoFur_WindVector;
			float _NeoFur_WindGustFactor;
			float _NeoFur_WindInfluence;

			float4 Frag(VertexFilterV2F vertex) : SV_Target
			{
				float3 windVector = _NeoFur_WindVector * _NeoFur_DeltaTime * _NeoFur_WindInfluence;
				windVector += float3(sin(_NeoFur_WindGustFactor * 5), cos(_NeoFur_WindGustFactor * 10), 0) * _NeoFur_WindGustFactor * 0.02;

				return float4(windVector, 0);
			}
			ENDCG
		}

		Pass
		{
			Name "RadialForce"
			Blend One One

			CGPROGRAM
			float _NeoFur_RadialForceInfluence;
			float3 _NeoFur_RadialForcePosition;
			float _NeoFur_RadialForceRadius;
			float _NeoFur_RadialForcePower;

			float3 RadialForce(float3 cpPosition)
			{
				float3 RadialForceVector = cpPosition - _NeoFur_RadialForcePosition;
				float RadialForceDistance = length(RadialForceVector);

				float3 outVelocity = 0;
				if (RadialForceDistance <= _NeoFur_RadialForceRadius)
				{
					float RadialForceScale = 1.0 - (RadialForceDistance / _NeoFur_RadialForceRadius);
					RadialForceVector /= RadialForceDistance;
					outVelocity += RadialForceVector * RadialForceScale * _NeoFur_RadialForceInfluence * _NeoFur_RadialForcePower;
				}

				return outVelocity;
			}

			float4 Frag(VertexFilterV2F vertex) : SV_Target
			{
				float3 previousLocalPosition = tex2D(_NeoFur_PreviousPositionTexture, vertex.uv).xyz;
				float3 previousWorldPosition = mul(_NeoFur_PreviousLocalToWorldMatrix, float4(previousLocalPosition, 1)).xyz;
				float3 cpPosition = tex2D(_NeoFur_PhysicsPositionTexture, vertex.uv).xyz;
				cpPosition += previousWorldPosition;

				float3 force = RadialForce(cpPosition);

				return float4(force, 0);
			}
			ENDCG
		}

		Pass
		{
			Name "ApplyPosition"

			CGPROGRAM

			struct FragmentOutput
			{
				float4 position : SV_Target0;
				float4 normal : SV_Target1;
				float4 tangent : SV_Target2;
			};

			FragmentOutput Frag(VertexFilterV2F vertex)
			{
				FragmentOutput output;

				output.position = tex2D(_NeoFur_PositionTexture, vertex.uv);
				output.normal = tex2D(_NeoFur_NormalTexture, vertex.uv);
				output.tangent = tex2D(_NeoFur_TangentTexture, vertex.uv);

				float3 physicsPosition = tex2D(_NeoFur_PhysicsPositionTexture, vertex.uv).xyz;

				output.position.a = physicsPosition.x;
				output.normal.a = physicsPosition.y;
				output.tangent.a = physicsPosition.z;

				return output;
			}
			ENDCG
		}
		Pass
		{
			Name "Simulate"

			CGPROGRAM
			float3 _NeoFur_PhysicsGravityVector;
			float _NeoFur_SpringLengthStiffness;
			float _NeoFur_SpringAngleStiffness;
			float4 _NeoFur_MinMaxConstraints;
			float _NeoFur_SpringMultiplyer;
			float _NeoFur_AirResistanceMultiplyer;

			struct FragmentOutput
			{
				float4 position : SV_Target0;
				float4 velocity : SV_Target1;
			};

#ifdef SHADER_API_GLES
			bool isnan(float v)
			{
				return !(v < 0 || v >= 0);
			}
#endif

			void MaxAngleClamp(float3 vertPos, float3 normalizedSplineDir, inout float3 cpPos)
			{
				float	maxRads = _NeoFur_MinMaxConstraints.z * 3.14159 / 180.0;
				float3	cpOffset = (cpPos - vertPos);
				float	offsetLen = length(cpOffset);
				if (offsetLen < 0.0001)
				{
					return;	//close to vert, can't vary angle much
				}

				float3	normalizedOffset = cpOffset / offsetLen;
				float	d = dot(normalizedSplineDir, normalizedOffset);
				if (d > 0.999)
				{
					return;	//acos gets nannish near 1
				}
				float	ang = acos(d);
				if (ang <= maxRads)
				{
					return;
				}

				float3	goodVec = lerp(normalizedSplineDir, normalizedOffset, maxRads / ang);

				// Restore the length of the original offset.
				goodVec = normalize(goodVec);
				goodVec *= offsetLen;

				cpPos = goodVec + vertPos;
			}

			void MinMaxDistanceClamp(float3 vertPos, float splineLength, inout float3 cpPosition, inout float3 cpVelocity)
			{
				float3	cpVec = cpPosition - vertPos;
				float3	cpNormal = normalize(cpVec);
				float planeDist = dot(cpNormal, cpVelocity);

				float	dist = length(cpVec);
				float	maxDist = splineLength * _NeoFur_MinMaxConstraints.y;
				float	minDist = splineLength * _NeoFur_MinMaxConstraints.x;

				if (dist > maxDist)
				{
					float3	newOffset = (cpVec / dist) * maxDist * 0.999;
					cpPosition = vertPos + newOffset;
					cpVelocity = cpVelocity - cpNormal * planeDist;
				}
				else if (dist < minDist)
				{
					float3	newOffset = (cpVec / dist) * minDist * 1.001;
					cpPosition = vertPos + newOffset;
					cpVelocity = cpVelocity - cpNormal * planeDist;
				}
			}

			void Simulate(float3 previousVertexPosition, float3 vertexPosition, float3 targetPosition, inout float3 cpPosition, inout float3 cpVelocity)
			{
				float3 vertexToTarget = targetPosition - vertexPosition;
				float3 vertexToTargetDirection = normalize(vertexToTarget);
				float3 vertexToTargetLength = length(vertexToTarget);

				float3 vertexToCP = cpPosition - vertexPosition;
				float3 vertexToCPDirection = normalize(vertexToCP);

				float3 cpToTarget = targetPosition - cpPosition;
				float3 cpToTargetDirection = normalize(cpToTarget);

				float cpLength = length(vertexToCP);
				float lengthDiff = vertexToTargetLength - cpLength;

				float3 newVelocity = cpVelocity;
				float3 newPosition = cpPosition;
				//Gravity
				newVelocity += _NeoFur_PhysicsGravityVector*_NeoFur_DeltaTime;

				//Spring
				float angle = saturate(1.0-dot(vertexToTargetDirection, vertexToCPDirection));
				newVelocity += cpToTargetDirection*angle*_NeoFur_DeltaTime*_NeoFur_SpringAngleStiffness*_NeoFur_SpringMultiplyer;
				newVelocity += vertexToCPDirection*lengthDiff*_NeoFur_DeltaTime*_NeoFur_SpringLengthStiffness*_NeoFur_SpringMultiplyer;
				newPosition += newVelocity*2.0f*_NeoFur_DeltaTime;

				//Air resistance. Not deltatimed because its not in the original compute version.
				newVelocity *= _NeoFur_AirResistanceMultiplyer;

				MaxAngleClamp(vertexPosition, vertexToTargetDirection, newPosition);
				MinMaxDistanceClamp(vertexPosition, vertexToTargetLength, newPosition, newVelocity);

				cpVelocity = isnan(newVelocity) ? cpVelocity : newVelocity;
				cpPosition = isnan(newPosition) ? cpPosition : newPosition;
			}

			FragmentOutput Frag(VertexFilterV2F vertex)
			{
				float3 localPosition = tex2D(_NeoFur_PositionTexture, vertex.uv).xyz;
				float3 worldPosition = mul(_NeoFur_LocalToWorldMatrix, float4(localPosition, 1)).xyz;

				float3 previousLocalPosition = tex2D(_NeoFur_PreviousPositionTexture, vertex.uv).xyz;
				float3 previousWorldPosition = mul(_NeoFur_PreviousLocalToWorldMatrix, float4(previousLocalPosition, 1)).xyz;

				float3 localNormal = tex2D(_NeoFur_NormalTexture, vertex.uv).xyz;
				float3 localTangent = tex2D(_NeoFur_TangentTexture, vertex.uv).xyz;
				float3 localBinormal = cross(localNormal, localTangent);
				float3 localGuideVector = FromTangentSpace(tex2D(_NeoFur_PhysicsGuideTexture, vertex.uv).xyz, localNormal, localBinormal, localTangent);
				float3 worldGuideVector = mul(_NeoFur_LocalToWorldMatrix, float4(localGuideVector, 0)).xyz;

				float3 targetPosition = worldPosition + worldGuideVector*_NeoFur_ShellDistance;

				float3 cpPosition = tex2D(_NeoFur_PhysicsPositionTexture, vertex.uv).xyz;
				cpPosition += previousWorldPosition;

				float3 cpVelocity = tex2D(_NeoFur_PhysicsVelocityTexture, vertex.uv).xyz;

				Simulate(previousWorldPosition, worldPosition, targetPosition, cpPosition, cpVelocity);

				cpPosition -= worldPosition;
				FragmentOutput output;
				output.position = float4(cpPosition, 1);
				output.velocity = float4(cpVelocity, 1);
				return output;
			}
			ENDCG
		}
	}
}
