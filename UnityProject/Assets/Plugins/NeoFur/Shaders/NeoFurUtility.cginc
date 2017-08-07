#ifndef NEOFUR_UTILITY_INCLUDED
#define NEOFUR_UTILITY_INCLUDED

inline float3 FromTangentSpace(float3 inVector, float3 normal, float3 binormal, float3 tangent)
{
	float3 v0 = float3(tangent.x, binormal.x, normal.x);
	float3 v1 = float3(tangent.y, binormal.y, normal.y);
	float3 v2 = float3(tangent.z, binormal.z, normal.z);

	float3 outNormal;
	outNormal.x = dot(v0, inVector);
	outNormal.y = dot(v1, inVector);
	outNormal.z = dot(v2, inVector);

	return outNormal;
}

inline float3 ToTangentSpace(float3 inVector, float3 normal, float3 binormal, float3 tangent)
{
	float3 outNormal;
	outNormal.x = dot(tangent, inVector);
	outNormal.y = dot(binormal, inVector);
	outNormal.z = dot(normal, inVector);

	return outNormal;
}

inline int Repeat(int value, int len)
{
#if defined(SHADER_API_D3D11)
	return (uint)value % (uint)len;
#else
	return value % len;
#endif
}

float2 NormalToSpherical(float3 cartesian)
{
	float2 spherical;

	spherical.x = atan2(cartesian.y, cartesian.x) / UNITY_PI;
	spherical.y = cartesian.z;

	return spherical;
}

float3 SphericalToNormal(float2 spherical)
{
	float2 sinCos;
	sinCos.x = sin(spherical.x * UNITY_PI);
	sinCos.y = cos(spherical.x * UNITY_PI);
	float xyScale = sqrt(1.0 - spherical.y * spherical.y);

	return float3(sinCos.y * xyScale, sinCos.x * xyScale, spherical.y);
}

//not sure if I'm wasting better instructions, but had some
//annoyances with mul on GL
//Remember Abrash's black book? :)
float3 RotateByProjection(float4x4 mat, float3 vec)
{
	float3	ret;

	ret.x = dot(mat[0].xyz, vec);
	ret.y = dot(mat[1].xyz, vec);
	ret.z = dot(mat[2].xyz, vec);

	return	ret;
}

float4 GetNormalizedQuaternion(float4 quaternion)
{
	float magnitude = sqrt(quaternion.x * quaternion.x +
		quaternion.y * quaternion.y +
		quaternion.z * quaternion.z +
		quaternion.w * quaternion.w);

	return quaternion / magnitude;
}

float4 GetQuaternionInverse(float4 quaternion)
{
	quaternion.x *= -1;
	quaternion.y *= -1;
	quaternion.z *= -1;

	return quaternion;
}

//make sure the input quaternion is normalized before calling this function
float4x4 GetRotationMatrixFromQuaternion(float4 quaternion)
{
	float x = quaternion.x;
	float y = quaternion.y;
	float z = quaternion.z;
	float w = quaternion.w;

	float x2 = x * x;
	float y2 = y * y;
	float z2 = z * z;

	return float4x4(1 - 2 * y2 - 2 * z2, 2 * x * y - 2 * w * z, 2 * x * z + 2 * w * y, 0,
					2 * x * y + 2 * w * z, 1 - 2 * x2 - 2 * z2, 2 * y * z + 2 * w * x, 0,
					2 * x * z - 2 * w * y, 2 * y * z - 2 * w * x, 1 - 2 * x2 - 2 * y2, 0,
					0,			 0,			  0,		   1);
}

float4 GetQuaternion(float3 axis, float angle)
{
	float halfAngle = angle / 2;

	return float4(axis.x * sin(halfAngle), axis.y * sin(halfAngle), axis.z * sin(halfAngle), cos(halfAngle));
}

float3 RotateAboutAxis(float3 axis, float angle, float3 pivot, float3 pos)
{
	float4 quat = GetQuaternion(axis, angle);

	float4x4 rot = GetRotationMatrixFromQuaternion(quat);

	//return rot * position
	return RotateByProjection(rot, pos);
}

#endif
