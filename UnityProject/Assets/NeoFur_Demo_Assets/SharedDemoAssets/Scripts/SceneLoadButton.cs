using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

namespace Neoglyphic.NeoFur.Demo
{
	public class SceneLoadButton : MonoBehaviour
	{
		public MeshRenderer buttonMeshRenderer;
		public Transform buttonTransform;
		public Material onMaterial;
		public Material offMaterial;
		public float buttonPressDistance = 0.1f;
		public float buttonAnimationTime = 0.25f;
		public string sceneName;
		private static bool anyButtonIsActive = false;

		private void Start()
		{
			buttonMeshRenderer.sharedMaterial = offMaterial;
		}

		private void OnTriggerEnter(Collider other)
		{
			PlayerController playerController = other.GetComponentInParent<PlayerController>();
			if (playerController)
			{
				Activate();
			}
		}

		public void Activate()
		{
			if (anyButtonIsActive)
			{
				return;
			}
			StartCoroutine(ActivateAsync());
		}

		private IEnumerator ActivateAsync()
		{
			if (string.IsNullOrEmpty(sceneName))
			{
				yield break;
			}

			anyButtonIsActive = true;

			PlayerUIManager.current.ShowLoading();

			buttonMeshRenderer.sharedMaterial = onMaterial;

			float buttonPressRatio = 0;
			while (buttonPressRatio < 1.0f)
			{
				buttonPressRatio += Time.deltaTime/buttonAnimationTime;
				buttonTransform.localPosition = new Vector3(0, -buttonPressDistance*buttonPressRatio, 0);
				yield return 0;
			}
			buttonPressRatio = 1;
			buttonTransform.localPosition = new Vector3(0, -buttonPressDistance*buttonPressRatio, 0);
			
			SceneManager.LoadSceneAsync(sceneName);
			SceneManager.sceneLoaded += SceneLoaded;
		}

		private void SceneLoaded(Scene arg0, LoadSceneMode arg1)
		{
			anyButtonIsActive = false;
			PlayerUIManager.current.HideLoading();
			SceneManager.sceneLoaded -= SceneLoaded;
		}
	}
}
