using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class ButtonHighlight : MonoBehaviour , IPointerEnterHandler , IPointerExitHandler
{
    [SerializeField] GameObject myUnderline;
    [SerializeField] GameObject anotherUnderline;
    public void OnPointerEnter(PointerEventData eventData)
    {
        if(myUnderline != null)
        {
            myUnderline.SetActive(true);
            anotherUnderline.SetActive(false);
        }
    }
    public void OnPointerExit(PointerEventData eventData)
    {
        if(myUnderline != null)
        {
            myUnderline.SetActive(false);
        }
    }
}

