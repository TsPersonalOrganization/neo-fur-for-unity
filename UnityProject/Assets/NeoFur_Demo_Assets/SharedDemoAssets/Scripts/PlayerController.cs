using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Neoglyphic.NeoFur.Demo
{
	public class PlayerController:MonoBehaviour
	{
		private class PickupInfo
		{
			public Rigidbody rigidbody;
			public Vector3 localCenter;
			public Vector3 center
			{
				get
				{
					return rigidbody.transform.TransformPoint(localCenter);
				}
				set
				{
					localCenter = rigidbody.transform.InverseTransformPoint(value);
				}
			}
		}

		private CapsuleCollider _capsuleCollider;
		public CapsuleCollider capsuleCollider
		{
			get
			{
				return _capsuleCollider ? _capsuleCollider : _capsuleCollider = gameObject.GetComponent<CapsuleCollider>();
			}
		}

		private Rigidbody _playerRigidbody;
		public Rigidbody playerRigidbody
		{
			get
			{
				return _playerRigidbody ? _playerRigidbody : _playerRigidbody = gameObject.GetComponent<Rigidbody>();
			}
		}

		public bool useMobileInput
		{
			get
			{
				return forceMobileMode || Application.isMobilePlatform;
			}
		}

		public Transform cameraYawPivot;
		public Transform cameraPitchPivot;
		public float groundAcceleration = 50;
		public float airAcceleration = 5;
		public float runAccelerationScaler = 2.0f;
		public float groundDrag = 5;
		public float airDrag = 0.5f;
		public float jumpVelocity = 5.0f;
		public float footHeight = 0.5f;
		public float mouseSensitvity = 2.5f;
		public float mobileLookSensitivity = 150;
		public float maxPickupDistance = 3;
		public float pickupHoldDistance = 2;
		public float pickupStiffness = 400;
		public float pickupDamping = 20;
		public float throwVelocity = 15;

		public bool forceMobileMode = false;
        public UIJoystick leftJoystick;
        public UIJoystick rightJoystick;
        public Canvas mobileUI;

        private float cameraPitch;
		private PickupInfo pickupInfo;
		private bool isGrounded;

        private void Start()
        {
            CheckMobileState();
        }

        private void Update()
        {
            HandleCameraInput();

            UpdatePickupAndThrow();
        }

        private void CheckMobileState()
        {
            if (useMobileInput)
            {
				if(Application.isEditor)
				{
					Cursor.lockState = CursorLockMode.None;
				}
            }

            // disable enable mobile UI
            mobileUI.gameObject.SetActive(useMobileInput);
        }

        private void HandleCameraInput()
        {
			if (!useMobileInput)
            {
				if (Screen.fullScreen || Input.GetMouseButtonDown(0))
				{
					Cursor.lockState = CursorLockMode.Locked;
				}

				if (Cursor.lockState == CursorLockMode.Locked)
                {
                    float cursorY = Input.GetAxisRaw("Mouse Y");
                    float cursorX = Input.GetAxisRaw("Mouse X");

                    RotateCamera(cursorX, cursorY, mouseSensitvity);
                }

				if (!Screen.fullScreen && Input.GetKeyDown(KeyCode.Escape))
				{
					Cursor.lockState = CursorLockMode.None;
				}
			}
            else
            {
                if(rightJoystick.IsDragging)
                {
					Vector2 offset = rightJoystick.GetJoystickOffset();
					offset = offset.normalized*Mathf.Pow(offset.magnitude, 2.5f);
					offset *= Time.deltaTime;
					RotateCamera(offset.x, offset.y, mobileLookSensitivity);
                }
            }

            bool doJump = Input.GetButtonDown("Jump");

            if (doJump)
            {
                if (isGrounded)
                {
                    Vector3 velocity = playerRigidbody.velocity;
                    velocity.y += jumpVelocity;
                    playerRigidbody.velocity = velocity;
                }
            }
        }

        private void RotateCamera(float cursorX, float cursorY, float sensitivity)
        {
            cameraPitch -= cursorY * sensitivity;
            cameraPitch = Mathf.Clamp(cameraPitch, -90, 90);
            cameraPitchPivot.localEulerAngles = new Vector3(cameraPitch, 0, 0);

            float yawDelta = cursorX * sensitivity;

            cameraYawPivot.Rotate(0, yawDelta, 0);
        }

        private void FixedUpdate()
        {
            Vector3 desiredMove = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
			desiredMove.Normalize();

			if (useMobileInput && leftJoystick != null)
            {
                if (leftJoystick.IsDragging)
                {
					Vector2 joystickOffset = leftJoystick.GetJoystickOffset();
					desiredMove += new Vector3(joystickOffset.x, 0, joystickOffset.y);
                }
            }

			if (desiredMove.magnitude > 1.0f)
			{
				desiredMove.Normalize();
			}

			desiredMove = cameraYawPivot.TransformDirection(desiredMove);

            //playerRigidbody.AddForce(Physics.gravity, ForceMode.Acceleration);
            Vector3 velocity = playerRigidbody.velocity;
            velocity += Physics.gravity * Time.fixedDeltaTime;
            playerRigidbody.velocity = velocity;

            UpdateGrounding();

            float acceleration = isGrounded ? groundAcceleration : airAcceleration;
            if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.LeftShift))
            {
                acceleration *= runAccelerationScaler;
            }

            velocity = playerRigidbody.velocity;
            velocity += desiredMove * acceleration * Time.fixedDeltaTime;

            float drag = isGrounded ? groundDrag : airDrag;
            float dragFactor = 1.0f / (1.0f + drag * Time.fixedDeltaTime);
            velocity.x *= dragFactor;
            velocity.z *= dragFactor;

            playerRigidbody.velocity = velocity;

            FixedUpdatePickUpAndThrow();
        }

		private void UpdateGrounding()
		{
			Ray groundingRay = new Ray(playerRigidbody.position, Vector3.down);
			float groundingDist = capsuleCollider.height/2+footHeight;
			RaycastHit groundHit;
			if (Raycast(groundingRay, out groundHit, groundingDist))
			{
				float footMidPointOffset = (groundingDist-footHeight/2);
				Vector3 footMidPoint = playerRigidbody.position+Vector3.down*footMidPointOffset;
				if (footMidPoint.y <= groundHit.point.y)
				{
					Vector3 targetPosition = groundHit.point+Vector3.up*footMidPointOffset;
					targetPosition.y -= 0.001f;
					playerRigidbody.position = Vector3.Lerp(playerRigidbody.position, targetPosition, 20.0f*Time.fixedDeltaTime);
					if (playerRigidbody.velocity.y < 0)
					{
						Vector3 v = playerRigidbody.velocity;
						v.y = 0;
						playerRigidbody.velocity = v;
					}
				}
				isGrounded = true;
			}
			else
			{
				isGrounded = false;
			}
		}

		private void UpdatePickupAndThrow()
		{
            bool isMobileDragging = useMobileInput && (leftJoystick.IsDragging || rightJoystick.IsDragging);

            if (isMobileDragging) return;

            bool doPickup = (useMobileInput && !Application.isEditor) ? Input.touchCount > 0 : Input.GetMouseButtonDown(0);

			if (doPickup)
			{
				if (pickupInfo != null)
				{
					DropPickup();
				}
				else
				{
					TryPickup();
				}
			}
			else if (Input.GetMouseButtonDown(1))
			{
				if (pickupInfo != null)
				{
					ThrowPickup();
				}
			}
		}

		private void ThrowPickup()
		{
			pickupInfo.rigidbody.velocity += cameraPitchPivot.forward*throwVelocity;
			Vector3 torqueVector = new Vector3(Random.Range(-180.0f, 180.0f), Random.Range(-180.0f, 180.0f), Random.Range(-180.0f, 180.0f));
			torqueVector *= 0.25f;
			pickupInfo.rigidbody.AddTorque(torqueVector, ForceMode.VelocityChange);
			DropPickup();
		}

		private void DropPickup()
		{
			foreach (var collider in pickupInfo.rigidbody.GetComponentsInChildren<Collider>())
			{
				Physics.IgnoreCollision(capsuleCollider, collider, false);
			}
			pickupInfo = null;
		}

		private void TryPickup()
		{
			Ray ray = new Ray(cameraPitchPivot.transform.position, cameraPitchPivot.transform.forward);
			RaycastHit hit;
			if (Raycast(ray, out hit, maxPickupDistance))
			{
				Rigidbody rb = hit.collider.gameObject.GetComponentInParent<Rigidbody>();
				if (rb)
				{
					pickupInfo = new PickupInfo();
					pickupInfo.rigidbody = rb;
					float divFactor = 0;
					Vector3 center = Vector3.zero;
					foreach (var collider in pickupInfo.rigidbody.GetComponentsInChildren<Collider>())
					{
						Vector3 size = collider.bounds.size;
						float volume = size.x*size.y*size.z;
						center += collider.bounds.center*volume;
						divFactor += volume;

						Physics.IgnoreCollision(capsuleCollider, collider, true);
					}
					center /= divFactor;
					pickupInfo.center = center;
				}
			}
		}

		private void FixedUpdatePickUpAndThrow()
		{
			if (pickupInfo == null)
			{
				return;
			}

			Vector3 targetPoint = cameraPitchPivot.position+cameraPitchPivot.transform.forward*pickupHoldDistance;
			Vector3 vectorToTarget = targetPoint-pickupInfo.center;

			Vector3 velocityAdd = vectorToTarget*pickupStiffness*Time.fixedDeltaTime;
			
			Vector3 newVelocity = pickupInfo.rigidbody.velocity+velocityAdd;
			newVelocity = Vector3.Lerp(newVelocity, playerRigidbody.velocity, pickupDamping*Time.fixedDeltaTime);
			pickupInfo.rigidbody.velocity = newVelocity;

			Vector3 newAngularVelocity = pickupInfo.rigidbody.angularVelocity;
			newAngularVelocity = Vector3.Lerp(newAngularVelocity, Vector3.zero, 2.0f*Time.fixedDeltaTime);
			pickupInfo.rigidbody.angularVelocity = newAngularVelocity;
		}

		/// <summary>
		/// Special raycast to ignore any colliders attached to this <see cref="GameObject"/>.
		/// </summary>
		private bool Raycast(Ray ray, out RaycastHit hit, float distance)
		{
			List<RaycastHit> hits = Physics.RaycastAll(ray, distance, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore).ToList();
			hits.RemoveAll(h => h.collider.transform.IsChildOf(transform));
			if (pickupInfo != null)
			{
				hits.RemoveAll(h => h.collider.transform.IsChildOf(pickupInfo.rigidbody.transform));
			}
			hits.Sort((a, b) => { return a.distance.CompareTo(b.distance); });
			hit = hits.FirstOrDefault();
			return hits.Count > 0;
		}
	}
}
