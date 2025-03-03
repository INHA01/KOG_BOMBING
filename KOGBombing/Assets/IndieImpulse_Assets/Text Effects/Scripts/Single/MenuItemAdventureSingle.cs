using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;
using System.Collections;

namespace IndieImpulseAssets
{
    public class MenuItemAdventureSingle : TextMenuItem, IPointerEnterHandler, IPointerExitHandler,IPointerClickHandler
    {
        public GameObject childTextObject;
        private AdventureTextEffectSingle menuManager;


        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<AdventureTextEffectSingle>();
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