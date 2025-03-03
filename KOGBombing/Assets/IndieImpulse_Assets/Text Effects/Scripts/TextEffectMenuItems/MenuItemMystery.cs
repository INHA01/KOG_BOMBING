using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;
using System.Collections;

namespace IndieImpulseAssets
{
    public class MenuItemMystery : TextMenuItem, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public GameObject childTextObject;
        private MainMenuManagerMystery menuManager;


        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<MainMenuManagerMystery>();
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            if (!menuManager.OnClick)
                menuManager.SetHover(this);
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            if (!menuManager.OnClick)
                menuManager.ResetHover(this);
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (menuManager.OnClick)
                menuManager.OnTextClicked(this);
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

        public void EnableShadowEffect()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<TextShadowEffect>().enabled = true;
            }

        }

        public void DisableShadowEffect()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<TextShadowEffect>().enabled = false;
            }

        }

    }
}