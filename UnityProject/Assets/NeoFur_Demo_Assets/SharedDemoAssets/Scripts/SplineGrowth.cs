using UnityEngine;
using System.Collections;
using NeoFurUnityPlugin;

namespace Neoglyphic.NeoFur.Demo
{
	public class SplineGrowth : MonoBehaviour
	{
		public float minLength = 0.5f;
		public float maxLength = 1.25f;
		public float speed = 0.25f;

		private NeoFurAsset _neoFurAsset;
		public NeoFurAsset newFurAsset
		{
			get
			{
				return _neoFurAsset ? _neoFurAsset : _neoFurAsset = gameObject.GetComponent<NeoFurAsset>();
			}
		}
		
		void Update()
		{
			float factor = Mathf.PingPong(speed*Time.timeSinceLevelLoad, 1);
			newFurAsset.ShellDistance = Mathf.SmoothStep(minLength, maxLength, factor);
		}
	}
}
