using UnityEngine;
using System.Collections;

public class AnimateUVs : MonoBehaviour {

    public string propertyName = "_HeightMapUND";
    public Vector2 uvAnimSpeed;
    private Vector2 uvs;
    public NeoFurUnityPlugin.NeoFurAsset furAsset;
	// Use this for initialization
	void Start ()
    {
        //uvs = furAsset.mMatInstance.GetTextureOffset(propertyName);
        if (furAsset == null)
        {
            furAsset = GetComponent<NeoFurUnityPlugin.NeoFurAsset>();

            if (furAsset == null)
            {
                Debug.Log("Disabling uv animation. no fur asset specified");
                this.enabled = false;
            }
        }
	}
	
	// Update is called once per frame
	void Update () {
        furAsset.material.SetTextureOffset(propertyName, uvs);
        uvs += uvAnimSpeed * Time.deltaTime;
    }
}
