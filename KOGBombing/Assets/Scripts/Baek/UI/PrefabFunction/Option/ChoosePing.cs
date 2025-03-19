using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ChoosePing : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField] Image mark;
    [SerializeField] PingCursorType pingCursorType;
    [SerializeField] PingSystem pingSystem;
    [SerializeField] ChoosePing[] choosePings = new ChoosePing[3];
    public void OnPointerEnter(PointerEventData eventData)
    {
        ImageShow(true);
        for(int i = 0; i < choosePings.Length; i++)
        {
            choosePings[i].ImageShow(false);
        }
        pingSystem.pingCursorType = pingCursorType;
    }
    public void OnPointerExit(PointerEventData eventData)
    {
        ImageShow(false);
    }
    public void ImageShow(bool isFade)
    {
        Color color = mark.color;
        color.a = isFade ? 1 : 0;
        mark.color = color;
    }
}
