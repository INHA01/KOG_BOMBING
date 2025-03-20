using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
namespace BAEK
{
    public class ChooseEmoticon : ChooseMarker , IPointerClickHandler
    {
        [SerializeField] PingPos pingPos;
        [SerializeField] MyProfileEdit myProfileEdit;
        public bool isClick = false;
        public override void OnPointerEnter(PointerEventData eventData)
        {
            base.OnPointerEnter(eventData);
        }
        public override void OnPointerExit(PointerEventData eventData)
        {
            if(!isClick)
                base.OnPointerExit(eventData);
            for(int i = 0; i < choosePings.Length; i++)
            {
                if (choosePings[i] is ChooseEmoticon a && a.isClick)
                    a.ImageShow(true);
                else
                    choosePings[i].ImageShow(false);
            }
        }
        public void OnPointerClick(PointerEventData eventData)
        {
            ImageShow(true);
            myProfileEdit.pingPos = pingPos;
            isClick = true;
            for (int i = 0; i < choosePings.Length; i++)
            {
                if (choosePings[i] is ChooseEmoticon a)
                    a.isClick = false;
            }
        }
    }

}

