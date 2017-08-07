using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using System;

public class UIJoystick : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    public float MaxScreenDisplacement = 50f;

    private RectTransform rectTransform;
    private Vector2 m_startPos;
    private Vector2 anchorPos;
    private Vector2 m_currentOffset;

    private bool isOver = false;
    private bool wasClicked = false;
    private bool isDragging = false;

    //might need to use something different for the phone
    public void OnPointerEnter(PointerEventData eventData)
    {
        isOver = true;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        isOver = false;
    }

    // Use this for initialization
    void Start ()
    {
        rectTransform = GetComponent<RectTransform>();
        m_startPos = rectTransform.anchoredPosition;
	}

    // Update is called once per frame
    void Update ()
    {
        bool isClicked = Application.isEditor ? Input.GetMouseButton(0) : Input.touchCount > 0;

        Vector2 cursorPos = Application.isEditor ? new Vector2(Input.mousePosition.x, Input.mousePosition.y) : Input.touches[0].position;

        if (isOver)
        {
            if(isClicked && !wasClicked)
            {
                isDragging = true;
                anchorPos = cursorPos;
            }
        }

        if (isDragging)
        {
            m_currentOffset = cursorPos - anchorPos;

            if (m_currentOffset.magnitude > MaxScreenDisplacement)
                m_currentOffset = m_currentOffset.normalized * MaxScreenDisplacement;
            
            if(!isClicked && wasClicked)
            {
                isDragging = false;
                m_currentOffset = Vector2.zero;
            }
        }

        rectTransform.anchoredPosition = m_startPos + m_currentOffset;
        wasClicked = isClicked;
	}

    public bool IsDragging
    {
        get { return isDragging; }
    }

    public Vector2 GetJoystickOffset()
    {
        Vector2 unscaledVector = m_currentOffset / MaxScreenDisplacement;
        if (unscaledVector.magnitude > 1)
            return unscaledVector.normalized;
        return unscaledVector;
    }
}
