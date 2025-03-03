using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class FantasyTextEffectSingle : MainMenuManager
    {
        public MenuItemFantasySingle menuItem;
        public GameObject SelectionEffect;
        public float selectionEffectOffsetY;
        void Start()
        {
       


            // Hide SelectionEffect initially
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(false);
            }


        
        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);


            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
        }


        public void SetHover(MenuItemFantasySingle item, bool isarrowkey = false)
        {
            SmoothTransitionMatColor smoothTransitionMatColor;
             

            smoothTransitionMatColor = item.GetComponent<SmoothTransitionMatColor>();
            smoothTransitionMatColor.enabled = false;
            smoothTransitionMatColor.enabled = true;


            SelectionEffect.SetActive(true);
            SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;

            SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = true;

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            }

          
        }

        public void SetEffectRecTransform(MenuItemFantasySingle menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
        {
            // Get the RectTransform components
            RectTransform menuItemRect = menuitem.GetComponent<RectTransform>();
            RectTransform selectionEffectRect = rectTransform;

            // Get the world position of menuitem's RectTransform
            Vector3 menuItemWorldPos = menuItemRect.position;

            // Apply the y-offset if needed

            menuItemWorldPos.y += yOffsetValue;

            // Set the SelectionEffect's world position to match menuitem's world position
            selectionEffectRect.position = menuItemWorldPos;

            // Set the width of SelectionEffect to match menuitem's width
            if (width)
                selectionEffectRect.sizeDelta = new Vector2(menuItemRect.rect.width, selectionEffectRect.sizeDelta.y);
        }


        public void ResetHover()
        {
            menuItem.DisableChildText();
            menuItem.SetMaterial(normalFont);
            SelectionEffect.SetActive(false);
            SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;

            SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = false;


             menuItem.GetComponent<SmoothTransitionMatColor>().enabled = false; 
        }

        

    }
}