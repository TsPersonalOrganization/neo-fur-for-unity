using UnityEngine;
using System.Collections;

namespace Neoglyphic.NeoFur.Demo
{
	public class Spin : MonoBehaviour
	{
		float mRotP, mRotY, mRotR;

		public float SpinRate = 30f;


		void Start()
		{
		}


		void Update()
		{
			mRotP   +=Time.deltaTime * SpinRate;
			mRotY   +=Time.deltaTime * SpinRate * 0.5f;
			mRotR   +=Time.deltaTime * SpinRate * 0.25f;

			transform.rotation  =Quaternion.Euler(mRotP, mRotY, mRotR);
		}
	}
}
