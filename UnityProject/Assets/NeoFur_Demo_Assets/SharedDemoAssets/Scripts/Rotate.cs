using UnityEngine;
using System.Collections;

namespace Neoglyphic.NeoFur.Demo
{
	public class Rotate : MonoBehaviour
	{

		// Use this for initialization
		void Start()
		{

		}

		// Update is called once per frame
		void Update()
		{
			transform.Rotate(0, 700 * Time.deltaTime, 0);
		}
	}
}
