using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

namespace BAEK
{ 
    public class ChooseShowEmoticon : ChooseMarker
    {
        [SerializeField] PingPos pingPos;
        [SerializeField] Emoticon emoticon;
        public override void OnPointerEnter(PointerEventData eventData)
        {
            base.OnPointerEnter(eventData);
            emoticon.pingPos = pingPos;
        }
    }
}
