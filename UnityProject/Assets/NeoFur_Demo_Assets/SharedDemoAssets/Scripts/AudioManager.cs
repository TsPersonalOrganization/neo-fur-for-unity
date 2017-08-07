using UnityEngine;
using System.Collections.Generic;

public class AudioManager : MonoBehaviour
{
    // AudioManager Singleton
    private static AudioManager m_instance;
    public static AudioManager Instance
    {
        private set
        {
            if(m_instance != null && m_instance != value)
            {
                Debug.LogWarning("There is already an AudioManager present in the scene. Remember, should only be one with a Singleton. Deleting the gameobject the \"new\" one is attached to.");
                Destroy(value.gameObject);

                return;
            }

            if(m_instance == null)
            {
                m_instance = value;
            }
        }
        get
        {
            if(m_instance == null)
            {
                GameObject gm = GameObject.FindGameObjectWithTag("GameManager");

                if (gm == null)
                {
                    Debug.LogWarning("Trying to retrieve component from GameManager but no GO tagged as GameManager exists in the current scene(s). Creating one now...");

                    gm = new GameObject("GameManager");
                    gm.tag = "GameManager";
                }

                m_instance = gm.GetComponent<AudioManager>();

                if(m_instance == null)
                {
                    Debug.LogError("GameManager GO found but no instance of AudioManager is attached. Attaching one now... Not all references will be set up properly.");

                    m_instance = gm.AddComponent<AudioManager>();
                }
            }

            return m_instance;
        }
    }

    public AudioClip[] AudioClips;

    private Dictionary<string, AudioClip> m_audioClipDictionary;

	// Use this for initialization
	void Start ()
    {
        //set Singleton instance to "this" if this hasnt happened already
        m_instance = this;

        m_audioClipDictionary = new Dictionary<string, AudioClip>();

        for(int i = 0; i < AudioClips.Length; ++ i)
        {
            AudioClip clip = AudioClips[i];

            if(clip == null)
            {
                Debug.LogWarning("Attempting to add NULL clip. Skipping...");

                continue;
            }

            if(!m_audioClipDictionary.ContainsKey(clip.name))
            {
                m_audioClipDictionary.Add(clip.name, clip);
            }
            else
            {
                Debug.LogWarning("Trying to add an AudioClip that already exists (by name) in the AudioManager. Change the clip or the file name.");
            }
        }
	}
	
    /// <summary>
    /// Play an AudioClip by a given name if it exists in the AudioManager
    /// </summary>
    /// <param name="name"></param>
    public void Play(string name)
    {
        Play(name, this.transform.position);
    }

    public void Play(string name, Vector3 position)
    {
        if (m_audioClipDictionary.ContainsKey(name))
        {
            AudioSource.PlayClipAtPoint(m_audioClipDictionary[name], position);
        }
    }

    /// <summary>
    /// Allow user to play audio clip that exists outside the AudioManager if they chose to.
    /// Remember, this AudioClip will not be managed by the AudioManager.
    /// </summary>
    /// <param name="clip"></param>
    public void Play(AudioClip clip)
    {

    }

	// Update is called once per frame
	void Update () {
	
	}

    void OnDisable()
    {
        // free up the Singleton reference if this is the Singleton
        if(m_instance == this)
        {
            m_instance = null;
        }
    }
}
