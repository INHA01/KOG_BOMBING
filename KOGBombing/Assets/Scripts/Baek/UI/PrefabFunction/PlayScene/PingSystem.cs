using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PingSystem : MonoBehaviour
{
    [Header("Ping")]
    public Ping[] pings = new Ping[(int)PingCursorType.Max];
    [SerializeField] GameObject pingUI;
    public PingCursorType pingCursorType;
    Vector2 mousePos;
    void Start()
    {
        for (int i = 0; i < (int)PingCursorType.Max; i++)
        {
            pings[i].Init();
        }
    }
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            mousePos = Input.mousePosition;
            pingUI.SetActive(true);
            pingUI.transform.position = mousePos;
        }
        else if(Input.GetKeyUp(KeyCode.T))
        {
            ShowPingCursor(mousePos);
            pingUI.SetActive(false);
        }
    }
    public void ShowPingCursor(Vector2 pos)
    {
        pings[(int)pingCursorType].Active(pos);
    }
}
