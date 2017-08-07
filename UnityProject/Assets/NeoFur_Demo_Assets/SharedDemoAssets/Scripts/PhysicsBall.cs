using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Neoglyphic.NeoFur.Demo
{
	public class PhysicsBall : MonoBehaviour
	{
		private Rigidbody _ballRigidbody;
		public Rigidbody ballRigidbody
		{
			get
			{
				return _ballRigidbody ? _ballRigidbody : _ballRigidbody = gameObject.GetComponent<Rigidbody>();
			}
		}

		public Transform controlBone;
		public Transform animationBone;
		private Quaternion defaultRotation;

		public HashSet<PhysicsBallAnchor> anchors = new HashSet<PhysicsBallAnchor>();
		public float animationWeight = 1;

		private void Awake()
		{
			defaultRotation = controlBone.localRotation;
		}

		private void Update()
		{
			//Hacky transform stuff to control animation amount with weight.
			controlBone.rotation = animationBone.rotation;
			controlBone.localRotation = Quaternion.Lerp(defaultRotation, controlBone.localRotation, animationWeight);
		}

		private PhysicsBallAnchor GetClosestAnchor()
		{
			anchors.RemoveWhere(v => !v);

			PhysicsBallAnchor best = null;
			float bestDist = Mathf.Infinity;
			foreach (var anchor in anchors)
			{
				float dist = Vector3.Distance(anchor.transform.position, transform.position);
				if (dist < bestDist)
				{
					best = anchor;
					bestDist = dist;
				}
			}

			return best;
		}

		private void FixedUpdate()
		{
			PhysicsBallAnchor anchor = GetClosestAnchor();

			if (!anchor)
			{
				UpdateAnimationWeight(-5);
				return;
			}

			Vector3 ballPosition = ballRigidbody.position;
			Vector3 vectorToBall = ballPosition - anchor.targetPosition;
			float distanceToBall = vectorToBall.magnitude;
			Vector3 normalToBall = vectorToBall.normalized;

			float distanceRatio = Mathf.Clamp01(distanceToBall / anchor.radius);

			Vector3 velocity = ballRigidbody.velocity;

			Vector3 force = -normalToBall * anchor.pullForce * distanceRatio;
			force += -Physics.gravity;
			velocity += force * Time.fixedDeltaTime;

			velocity /= 1.0f + anchor.damper * Time.fixedDeltaTime;

			ballRigidbody.velocity = velocity;

			Vector3 angularVelocity = ballRigidbody.angularVelocity;

			Quaternion anchorRelativeRotation = Quaternion.Inverse(anchor.transform.rotation) * transform.rotation;
			Vector3 anchorRelativeEulerAngles = anchorRelativeRotation.eulerAngles;
			Vector3 correctionTorque = new Vector3();
			correctionTorque.x = Mathf.DeltaAngle(anchorRelativeEulerAngles.x, 0);
			correctionTorque.y = Mathf.DeltaAngle(anchorRelativeEulerAngles.y, 0);
			correctionTorque.z = Mathf.DeltaAngle(anchorRelativeEulerAngles.z, 0);
			correctionTorque = anchor.transform.TransformDirection(correctionTorque);

			angularVelocity += correctionTorque * Mathf.Deg2Rad * anchor.angularCorrection * Time.fixedDeltaTime;
			angularVelocity /= 1.0f + anchor.angularDamper * Time.fixedDeltaTime;

			ballRigidbody.angularVelocity = angularVelocity;

			if (velocity.magnitude < 1.0)
			{
				UpdateAnimationWeight(1);
			}
		}

		private void UpdateAnimationWeight(float rate)
		{
			animationWeight = Mathf.Clamp01(animationWeight + rate * Time.fixedDeltaTime);
		}
	}
}
