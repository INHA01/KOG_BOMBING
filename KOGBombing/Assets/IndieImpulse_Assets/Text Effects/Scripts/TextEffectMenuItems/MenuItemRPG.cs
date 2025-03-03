using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;
using System.Collections;

namespace IndieImpulseAssets
{
    public class MenuItemRPG : TextMenuItem, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public GameObject childTextObject;
        private MainMenuManagerRPG menuManager;


        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<MainMenuManagerRPG>();
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

        public void EnableFadeEffect()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<TextFade>().enabled = true;
            }

        }

        public void DisableFadeEffect()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<TextFade>().enabled = false;
            }

        }




        public void EnableScaleTransition()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<ScaleTransition>().enabled = true;
            }

        }

        public void DisableScaleTransition()
        {
            if (childTextObject != null)
            {
                childTextObject.GetComponent<ScaleTransition>().enabled = false;
            }

        }

    }
}