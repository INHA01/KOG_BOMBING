using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public abstract class ChooseMarker : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField] Image mark;
    [SerializeField] protected ChooseMarker[] choosePings = new ChoosePing[3];
    public virtual void OnPointerEnter(PointerEventData eventData)
    {
        ImageShow(true);
        for (int i = 0; i < choosePings.Length; i++)
        {
            choosePings[i].ImageShow(false);
        }
    }

    public virtual void OnPointerExit(PointerEventData eventData)
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
