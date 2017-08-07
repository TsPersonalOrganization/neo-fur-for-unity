using UnityEngine;
using System.Collections;

namespace Neoglyphic.NeoFur.Demo
{
	public class LightLod : MonoBehaviour
	{
		private Light _light;
		public Light lightComponent
		{
			get
			{
				return _light ? _light : _light = gameObject.GetComponent<Light>();
			}
		}

		public float maxShadowDistance = 50;
		[Range(0, 1)]
		public float shadowFadeRatio = 0.8f;
		[Range(0, 1)]
		public float spotLightCenterRatio = 0.5f;

		private LightShadows lastShadowMode;

		private void Update()
		{
			if (!lightComponent)
			{
				return;
			}

			if (lightComponent.isBaked)
			{
				return;
			}

			if (lastShadowMode == LightShadows.None && lightComponent.shadows == LightShadows.None)
			{
				//Light doesnt have shadows.
				return;
			}

			Camera mainCamera = Camera.main;
			if (!mainCamera)
			{
				return;
			}

			Vector3 center = GetCenter();
			float distToLight = Vector3.Distance(mainCamera.transform.position, center);

			float distanceRatio = Mathf.Clamp01(distToLight/maxShadowDistance);
			
			if (distanceRatio >= 1)
			{
				if (lightComponent.shadows != LightShadows.None)
				{
					lastShadowMode = lightComponent.shadows;
					lightComponent.shadows = LightShadows.None;
				}
			}
			else
			{
				if (lightComponent.shadows == LightShadows.None)
				{
					lightComponent.shadows = lastShadowMode;
				}

				float fade = 1.0f-Mathf.Clamp01((distanceRatio-shadowFadeRatio)/(1.0f-shadowFadeRatio));
				if (lightComponent.shadowStrength != fade)
				{
					lightComponent.shadowStrength = fade;
				}
			}
		}

		private void OnDrawGizmosSelected()
		{
			if (!lightComponent)
			{
				return;
			}

			Vector3 center = GetCenter();
			Gizmos.color = new Color(1, 1, 1, 0.75f);
			Gizmos.DrawWireSphere(center, maxShadowDistance);
			Gizmos.color = new Color(1, 1, 1, 0.25f);
			Gizmos.DrawWireSphere(center, maxShadowDistance*shadowFadeRatio);
		}

		private Vector3 GetCenter()
		{
			if (lightComponent.type == LightType.Spot)
			{
				return transform.position+transform.forward*lightComponent.range*spotLightCenterRatio;
			}
			return transform.position;
		}
	}
}
