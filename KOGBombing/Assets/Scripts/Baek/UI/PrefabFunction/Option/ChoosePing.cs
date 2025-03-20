using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class ChoosePing : ChooseMarker
{
    [SerializeField] PingCursorType pingCursorType;
    [SerializeField] PingSystem pingSystem;
    public override void OnPointerEnter(PointerEventData eventData)
    {
        base.OnPointerEnter(eventData);
        pingSystem.pingCursorType = pingCursorType;
    }
}
