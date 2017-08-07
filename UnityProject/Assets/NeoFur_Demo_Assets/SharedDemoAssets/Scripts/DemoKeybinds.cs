using UnityEngine;
using NeoFurUnityPlugin;

/*

	Keybinds for demo environment

	Esc - Quit
	F1 - Toggle fur enabled
	F2 - 
	F3 - Decrement antialiasing
	F4 - Increment antialiasing
	F5 - Toggle triple buffering
	F6 - Toggle anisotropic filtering
	F7 - Toggle V-Sync
	F8 - Decrease quality level
	F9 - Increase quality level

*/
namespace Neoglyphic.NeoFur.Demo
{
	public class DemoKeybinds : MonoBehaviour
	{
		public bool FurEnabled = true;

		void Update()
		{
			// esc to quit
			if (Input.GetKey(KeyCode.Escape))
			{
				Application.Quit();
			}

			// toggle fur enabled
			if (Input.GetKeyDown(KeyCode.F1))
			{
				NeoFurAsset[] assets = FindObjectsOfType<NeoFurAsset>();
				if (FurEnabled)
				{
					foreach (NeoFurAsset nfa in assets)
					{
						nfa.enabled = false;
					}
					Debug.Log("NeoFur Components Disabled (F1)");
					FurEnabled = false;
				}
				else
				{
					foreach (NeoFurAsset nfa in assets)
					{
						nfa.enabled = true;
					}
					Debug.Log("NeoFur Components Enabled (F1)");
					FurEnabled = true;
				}
			}

			if (Input.GetKeyDown(KeyCode.F2))
			{
				Debug.Log(" (F2)");
			}

			// aa decrement
			if (Input.GetKeyDown(KeyCode.F3))
			{
				if (QualitySettings.antiAliasing > 0)
				{
					QualitySettings.antiAliasing    -=2;
					Debug.Log("Decreased AA to " + QualitySettings.antiAliasing + " (F3)");
				}
			}

			// aa increment
			if (Input.GetKeyDown(KeyCode.F4))
			{
				if (QualitySettings.antiAliasing < 8)
				{
					QualitySettings.antiAliasing    +=2;
					Debug.Log("Increased AA to " + QualitySettings.antiAliasing + " (F4)");
				}
			}

			// triple buffering toggle
			if (Input.GetKeyDown(KeyCode.F5))
			{
				if (QualitySettings.maxQueuedFrames < 3)
				{
					QualitySettings.maxQueuedFrames = 3;
					Debug.Log("Triple Buffering Enabled (F5)");
				}
				else if (QualitySettings.maxQueuedFrames >= 3)
				{
					QualitySettings.maxQueuedFrames = 0;
					Debug.Log("Triple Buffering Disabled (F5)");
				}
			}

			// anisotropic filtrering toggle
			if (Input.GetKeyDown(KeyCode.F6))
			{
				if (QualitySettings.anisotropicFiltering == AnisotropicFiltering.Disable)
				{
					QualitySettings.anisotropicFiltering = AnisotropicFiltering.ForceEnable;
					Debug.Log("Anisotropic Filtering Force Enabled (F6)");
				}
				else if (QualitySettings.anisotropicFiltering == AnisotropicFiltering.ForceEnable)
				{
					QualitySettings.anisotropicFiltering = AnisotropicFiltering.Disable;
					Debug.Log("Anisotropic Filtering Disabled (F6)");
				}
			}

			// vsync toggle
			if (Input.GetKeyDown(KeyCode.F7))
			{
				if (QualitySettings.vSyncCount <= 0)
				{
					QualitySettings.vSyncCount = 1;
					Debug.Log("V-Sync On (F7)");
				}
				else if (QualitySettings.vSyncCount >= 1)
				{
					QualitySettings.vSyncCount = 0;
					Debug.Log("V-Sync Off (F7)");
				}
			}

			// quality increment
			if (Input.GetKeyDown(KeyCode.F8))
			{
				QualitySettings.IncreaseLevel();
				Debug.Log("Increased Quality (F8)");
			}

			// quality decrement
			if (Input.GetKeyDown(KeyCode.F9))
			{
				QualitySettings.DecreaseLevel();
				Debug.Log("Decreased Quality (F9)");
			}
		}
	}
}
