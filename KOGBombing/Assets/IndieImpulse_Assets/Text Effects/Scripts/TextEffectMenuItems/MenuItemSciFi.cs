using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;
using System.Collections;

namespace IndieImpulseAssets
{
    public class MenuItemSciFi : TextMenuItem, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public GameObject childTextObject;
        private MainMenuManagerSciFi menuManager;


        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<MainMenuManagerSciFi>();
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


    }
}