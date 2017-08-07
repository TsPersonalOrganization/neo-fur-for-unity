using UnityEngine;
using System.Collections;

public class AnimateOnTriggerEnter : MonoBehaviour {
    public GameObject TargetGO;

    public AnimationCurve PosX;
    public AnimationCurve PosZ;
    public AnimationCurve PosY;

    public float AnimationTime = 1f;
    private float currAnimTime;
    private bool isAnimating = false;

    private Vector3 startPos;

    // Use this for initialization
    void Start () {

        startPos = TargetGO.transform.localPosition;

        resetAnimation();
	}
	
    void resetAnimation()
    {
        TargetGO.transform.localPosition = startPos;
        isAnimating = false;
        currAnimTime = 0;
    }

	// Update is called once per frame
	void Update ()
    {
	    if(isAnimating)
        {
            currAnimTime += Time.deltaTime;

            if(currAnimTime > AnimationTime)
            {
                currAnimTime = AnimationTime;
            }
        }
        else
        {
            currAnimTime -= Time.deltaTime;

            if(currAnimTime < 0)
            {
                currAnimTime = 0;
                resetAnimation();
            }
        }

        float t = currAnimTime / AnimationTime;
        TargetGO.transform.localPosition = startPos + new Vector3(PosX.Evaluate(t), PosY.Evaluate(t), PosZ.Evaluate(t));
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            isAnimating = true;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            isAnimating = false;
        }
    }
}
