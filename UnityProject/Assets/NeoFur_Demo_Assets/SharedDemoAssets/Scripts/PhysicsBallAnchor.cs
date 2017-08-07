using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Neoglyphic.NeoFur.Demo
{
	public class PhysicsBallAnchor : MonoBehaviour
	{
		public Transform rotationTarget;
		public float radius = 2;
		public float pullForce = 10;
		public float damper = 0.25f;
		public float angularDamper = 0.25f;
		public float angularCorrection = 1.0f;

		private Vector3 targetPositionOffset;
		public Vector3 targetPosition
		{
			get
			{
				return targetPositionOffset + transform.position;
			}
		}

		private float lastTargetPositionChangeTime = Mathf.NegativeInfinity;

		private HashSet<PhysicsBall> physicsBalls = new HashSet<PhysicsBall>();

		private Collider[] overlappedColliderCache = new Collider[64];
		private void FixedUpdate()
		{
			if (Time.timeSinceLevelLoad - lastTargetPositionChangeTime > 1.0f)
			{
				targetPositionOffset = Random.insideUnitSphere * 0.05f;
				lastTargetPositionChangeTime = Time.timeSinceLevelLoad;
			}

			int colliderCount = 0;
			while (true)
			{
				colliderCount = Physics.OverlapSphereNonAlloc(targetPosition, radius, overlappedColliderCache);
				if (colliderCount < overlappedColliderCache.Length)
				{
					break;
				}
				overlappedColliderCache = new Collider[overlappedColliderCache.Length * 2];
			}


			//physicsBalls.RemoveWhere(v => !v);
			foreach (var ball in physicsBalls)
			{
				if (ball)
				{
					ball.anchors.Remove(this);
				}
			}
			physicsBalls.Clear();

			for (int i = 0; i < colliderCount; i++)
			{
				Collider collider = overlappedColliderCache[i];

				PhysicsBall physicsBall = collider.gameObject.GetComponent<PhysicsBall>();
				if (!physicsBall || physicsBall.ballRigidbody == null)
				{
					continue;
				}

				float distanceToBall = Vector3.Distance(targetPosition, physicsBall.transform.position);

				if (distanceToBall > radius)
				{
					continue;
				}

				physicsBalls.Add(physicsBall);
				physicsBall.anchors.Add(this);
			}
		}
	}
}
