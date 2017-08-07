using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditor.Rendering;

// This copy of NeoFur for Unity is licensed to swq_shan10@hotmail.com

namespace Neoglyphic.NeoFur.Editor
{
	/// <summary>
	/// This is a hack to be able to get and set the render path in both Unity 5.4 and 5.5+
	/// </summary>
	public static class NeoFurDeferredSettingsProxy
	{
#if UNITY_5_4
		public static RenderingPath renderingPath
		{
			get
			{
				return PlayerSettings.renderingPath;
			}
			set
			{
				PlayerSettings.renderingPath = value;
			}
		}
#else
		public static RenderingPath renderingPath
		{
			get
			{
				TierSettings tier = EditorGraphicsSettings.GetTierSettings(EditorUserBuildSettings.selectedBuildTargetGroup, Graphics.activeTier);
				return tier.renderingPath;
			}
			set
			{
				TierSettings tier = EditorGraphicsSettings.GetTierSettings(EditorUserBuildSettings.selectedBuildTargetGroup, Graphics.activeTier);
				tier.renderingPath = value;
				EditorGraphicsSettings.SetTierSettings(EditorUserBuildSettings.selectedBuildTargetGroup, Graphics.activeTier, tier);
			}
		}
#endif
	}
}
