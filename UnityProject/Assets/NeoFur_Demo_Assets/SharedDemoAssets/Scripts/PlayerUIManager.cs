using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace Neoglyphic.NeoFur.Demo
{
	public class PlayerUIManager : MonoBehaviour
	{
		private static PlayerUIManager _current;
		public static PlayerUIManager current
		{
			get
			{
				return _current ? _current : _current = FindObjectOfType<PlayerUIManager>();
			}
		}

		public Text fpsText;
		public Text loadingText;
		public Image crosshair;

		private float smoothDeltaTime = -1;

		private void Start()
		{
			HideLoading();
		}

		private void Update()
		{
			if (smoothDeltaTime < 0 && Time.deltaTime > 0)
			{
				smoothDeltaTime = Time.deltaTime;
			}
			else
			{
				smoothDeltaTime = Mathf.Lerp(smoothDeltaTime, Time.deltaTime, 1.0f*Time.deltaTime);
			}
			fpsText.text = (1.0f/smoothDeltaTime).ToString("0")+"fps";
		}

		public void ShowLoading()
		{
			loadingText.gameObject.SetActive(true);
			crosshair.gameObject.SetActive(false);
		}

		public void HideLoading()
		{
			loadingText.gameObject.SetActive(false);
			crosshair.gameObject.SetActive(true);
		}
	}
}
