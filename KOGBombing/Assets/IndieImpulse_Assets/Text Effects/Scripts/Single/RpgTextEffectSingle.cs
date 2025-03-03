using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class RpgTextEffectSingle : MainMenuManager
    {

     
        public MenuItemRPGSingle menuItem;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public float selectionEffectOffsetY;
        public float selectionEffect2OffsetY;
        void Start()
        {
            // Find all MenuItem components in the child objects


            // Hide SelectionEffect initially
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(false);
            }
            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(false);
            }

        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);
            SetEffectRecTransform(menuItem, SelectionEffect2.GetComponent<RectTransform>(), false, selectionEffect2OffsetY);

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);

            if (SelectionEffect2 != null)
                SelectionEffect2.SetActive(true);
        }

      
        public void SetHover(MenuItemRPGSingle item, bool isarrowkey = false)
        {

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            item.EnableFadeEffect();
            item.EnableScaleTransition();
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(true);
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(true);
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), false, selectionEffect2OffsetY);

            }

        }

        public void SetEffectRecTransform(MenuItemRPGSingle menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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
            menuItem.SetMaterial(normalFont);
            if (menuItem.transform.childCount > 0)
            {
                menuItem.DisableChildText();
                menuItem.DisableFadeEffect();
                menuItem.DisableScaleTransition();
            }
            SelectionEffect.SetActive(false);
            SelectionEffect2.SetActive(false);
        }

      

    }
}