using UnityEngine;
using System.Collections;
using NeoFurUnityPlugin;


namespace Neoglyphic.NeoFur.Demo
{
	public class RadialForceImpulse : MonoBehaviour
	{
		public float impulseInterval = 2;
		public float radius = 10;
		public float power = 15;

        public string NameOfSoundToBePlayed;

		private float lastExplosionTime = 0;

		void Start()
		{

		}


		void Update()
		{
			if (Time.timeSinceLevelLoad-lastExplosionTime > impulseInterval)
			{
				MakeExplosion();
				lastExplosionTime = Time.timeSinceLevelLoad;
			}
		}

		void MakeExplosion()
		{
			Vector3 position = transform.position;
			Collider[] colliders = Physics.OverlapSphere(position, radius);

			foreach (Collider collider in colliders)
			{
				Rigidbody rb = collider.GetComponent<Rigidbody>();
				if (rb != null)
				{
					//add force to unity's physics stuff
					rb.AddExplosionForce(power, position, radius, 3.0f);
				}

				//add force to neofur
				NeoFurAsset nfa = collider.gameObject.GetComponent<NeoFurAsset>();
				if (nfa)
				{
					RadialForce rf = new RadialForce();
					
					rf.Origin = position;
					rf.Radius = radius;
					rf.Strength = power;

					nfa.AddRadialForce(rf);

					if (!string.IsNullOrEmpty(NameOfSoundToBePlayed))
					{
						AudioManager.Instance.Play(NameOfSoundToBePlayed, this.transform.position);
					}
				}
			}
		}

		private void OnDrawGizmosSelected()
		{
			Gizmos.color = new Color(0.65f, 1.0f, 0.35f, 1);
			Gizmos.DrawWireSphere(transform.position, radius);
			Gizmos.color = Color.white;

			Collider[] colliders = Physics.OverlapSphere(transform.position, radius);
			foreach (Collider collider in colliders)
			{
				NeoFurAsset nfa = collider.gameObject.GetComponent<NeoFurAsset>();
				if (nfa)
				{
					Gizmos.DrawLine(transform.position, nfa.transform.position);
				}
			}
		}
	}
}
