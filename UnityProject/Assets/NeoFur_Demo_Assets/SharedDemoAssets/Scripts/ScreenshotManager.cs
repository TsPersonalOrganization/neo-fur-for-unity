using UnityEngine;
using System.Collections;
using System;

public class ScreenshotManager : MonoBehaviour {
    public KeyCode ScreenshotKey = KeyCode.F12;
    [Range(1, 8)]
    public int superSize = 2;

    private string fileName;
    private bool captureHD;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update ()
    {
        if(captureHD)
        {
            Debug.Log("Trying to save screenshot to: " + (fileName + "_HD.png"));
            Application.CaptureScreenshot(fileName + "_HD.png", superSize);
            captureHD = false;
        }
	    else if(Input.GetKeyDown(ScreenshotKey))
        {
            DateTime now = DateTime.Now;

            string date = now.Day + "." + now.Month + "." + now.Year;
            string time = now.Hour + "." + now.Minute + "." + now.Second;
            fileName = Application.dataPath + "/../../../media/images/NeoScreenie_" + date + "_" + time;

            Debug.Log("Trying to save screenshot to: " + (fileName + ".png"));
            Application.CaptureScreenshot(fileName + ".png");
            captureHD = true;
        }
	}
}
