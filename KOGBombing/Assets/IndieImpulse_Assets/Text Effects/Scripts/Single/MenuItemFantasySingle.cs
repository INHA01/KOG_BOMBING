using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;
using System.Collections;

namespace IndieImpulseAssets
{
    public class MenuItemFantasySingle : TextMenuItem, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public GameObject childTextObject;
        private FantasyTextEffectSingle menuManager;


        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<FantasyTextEffectSingle>();
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            if (!menuManager.OnClick)
                menuManager.SetHover(this);
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            if (!menuManager.OnClick)
                menuManager.ResetHover();
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (menuManager.OnClick)
                menuManager.SetHover(this);
        }
        public void DisableChildText()
        {
            if (childTextObject != null)
            {
                childTextObject.SetActive(false);
            }
        }

        public void EnableChildText()
        {
            if (childTextObject != null)
            {
                childTextObject.SetActive(true);
            }
        }


    }
}