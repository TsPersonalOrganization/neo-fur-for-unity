using UnityEngine;
using System.Collections;

namespace Neoglyphic.NeoFur.Demo
{
	public class EscToQuit : MonoBehaviour
	{
		public bool onlyInFullScreen;

		void Update()
		{
			if (Input.GetKeyDown(KeyCode.Escape))
			{
				if (!onlyInFullScreen || Screen.fullScreen)
				{
					Application.Quit();
				}
			}
		}
	}
}
