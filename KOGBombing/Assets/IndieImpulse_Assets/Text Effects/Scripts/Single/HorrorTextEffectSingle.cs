using System.Collections;
using UnityEditor;
using UnityEngine;

namespace IndieImpulseAssets
{
    public class HorrorTextEffectSingle : MainMenuManager
    {

     
        public MenuItemHorrorSingle menuItem;
        public GameObject SelectionEffect;
        public float EffectoffsetY; // Offset value for Y-axis
        void Start()
        {
            // Find all MenuItem components in the child objects
       


            // Hide SelectionEffect initially
            if (SelectionEffect != null)
                SelectionEffect.SetActive(false);


           

                if (OnClick)
                {
                menuItem.GetComponent<GlitchTextEffect>().Onclick = true;
                menuItem.transform.GetChild(0).GetComponent<GlitchTextEffect>().Onclick = true;
                }
                else
                {
                menuItem.GetComponent<GlitchTextEffect>().Onclick = false;
                menuItem.transform.GetChild(0).GetComponent<GlitchTextEffect>().Onclick = false;
                }

        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransformOffset(menuItem, SelectionEffect.GetComponent<RectTransform>());

            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
        }


        public void SetHover(MenuItemHorrorSingle item, bool isarrowkey = false)
        {

            SelectionEffect.SetActive(true);
            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (item.transform.childCount > 0)
                item.EnableChildGlitchEffect();
            item.EnablePingPongEffect();
            if (SelectionEffect != null)
                SetEffectRecTransformOffset(item, SelectionEffect.GetComponent<RectTransform>());
        }

        public void SetEffectRecTransformOffset(MenuItemHorrorSingle menuitem,RectTransform rectTransform)
        {
            RectTransform menuItemRect = menuitem.GetComponent<RectTransform>();
            RectTransform selectionEffectRect = rectTransform;

            // Get the world position of menuitem's RectTransform
            Vector3 menuItemWorldPos = menuItemRect.position;

            // Apply the y-offset if needed

            menuItemWorldPos.y += EffectoffsetY;

            // Set the SelectionEffect's world position to match menuitem's world position
            selectionEffectRect.position = menuItemWorldPos;

          

        }

        public void ResetHover()
        {
            menuItem.SetMaterial(normalFont);
            if (menuItem.transform.childCount > 0)
                menuItem.DisableChildText();
            if (menuItem.transform.childCount > 0)
                menuItem.DisableChildGlitchEffect();
            menuItem.DisablePingPongEffect();

            SelectionEffect.SetActive(false);

        }

       
    }
}