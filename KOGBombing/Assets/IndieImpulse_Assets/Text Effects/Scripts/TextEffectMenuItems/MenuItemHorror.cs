using UnityEngine;
using TMPro;
using UnityEngine.EventSystems;

namespace IndieImpulseAssets
{
    public class MenuItemHorror : TextMenuItem, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public GameObject childTextObject;
        private MainMenuManagerHorror menuManager;

        void Start()
        {
            tmpText = GetComponent<TextMeshProUGUI>();
            menuManager = FindObjectOfType<MainMenuManagerHorror>();

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

        public void DisableChildGlitchEffect()
        {
            if (childTextObject.GetComponent<GlitchEffect>() != null)
            {
                childTextObject.GetComponent<GlitchEffect>().enabled = false;
            }
        }
        public void EnableChildGlitchEffect()
        {
            if (childTextObject.GetComponent<GlitchEffect>() != null)
            {
                childTextObject.GetComponent<GlitchEffect>().enabled = true;
            }
        }
        public void DisableChildGlitchTextEffect()
        {
            if (GetComponent<GlitchTextEffect>() != null)
            {
                GetComponent<GlitchTextEffect>().StopGlitchEffect();
            }

            if (childTextObject.GetComponent<GlitchTextEffect>() != null)
            {
                childTextObject.GetComponent<GlitchTextEffect>().StopGlitchEffect();
            }
        }
        public void EnableChildGlitchTextEffect()
        {
            if (GetComponent<GlitchTextEffect>() != null)
            {
                GetComponent<GlitchTextEffect>().StartGlitchEffect();
            }
            if (childTextObject.GetComponent<GlitchTextEffect>() != null)
            {
                childTextObject.GetComponent<GlitchTextEffect>().StartGlitchEffect();
            }
        }

        public void DisablePingPongEffect()
        {
            if (GetComponent<PingPongTextMeshProMaterial>() != null)
            {
                GetComponent<PingPongTextMeshProMaterial>().enabled = false;
            }
        }
        public void EnablePingPongEffect()
        {
            if (GetComponent<PingPongTextMeshProMaterial>() != null)
            {
                DisablePingPongEffect();
                GetComponent<PingPongTextMeshProMaterial>().enabled = true;
            }
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