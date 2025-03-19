using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PingSystem : MonoBehaviour
{
    [Header("Ping")]
    public Ping[] pings = new Ping[(int)PingCursorType.Max];
    [SerializeField] GameObject[] pingIcons = new GameObject[(int)PingCursorType.Max];
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
    public void OnPing(InputValue value)
    {
        if (value.isPressed)
        {
            mousePos = Input.mousePosition;
            pingUI.SetActive(true);
            pingUI.transform.position = mousePos;
        }
        else 
        {
            ShowPing(mousePos);
            pingUI.SetActive(false);
        }
    }
    public void ShowPing(Vector2 pos)
    {
        pings[(int)pingCursorType].Active(pos);
        StartCoroutine(ShowPingUI(pos));
    }
    IEnumerator ShowPingUI(Vector2 pos)
    {
        pingIcons[(int)pingCursorType].SetActive(true);
        pingIcons[(int)pingCursorType].transform.position = pos;
        yield return new WaitForSeconds(3f);
        pingIcons[(int)pingCursorType].SetActive(false);
    }
}
