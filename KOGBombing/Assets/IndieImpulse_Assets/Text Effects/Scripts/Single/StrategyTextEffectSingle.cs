using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class StrategyTextEffectSingle : MainMenuManager
    {

      
        public MenuItemStrategySingle menuItem;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public float selectionEffectOffsetY;

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
            SetEffectRecTransform(menuItem, SelectionEffect2.GetComponent<RectTransform>(), true, 0);

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);

            if (SelectionEffect2 != null)
                SelectionEffect2.SetActive(true);
        }

        public void SetHover(MenuItemStrategySingle item, bool isarrowkey = false)
        {
            SmoothTransitionMatValue smoothTransitionMatValues;

            smoothTransitionMatValues = item.GetComponent<SmoothTransitionMatValue>();
            smoothTransitionMatValues.enabled = true;


            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(true);
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(true);
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), true, 0);

            }

        }

        public void SetEffectRecTransform(MenuItemStrategySingle menuitem, RectTransform rectTransform, bool width, float xOffsetValue)
        {
            // Get the RectTransform components
            RectTransform menuItemRect = menuitem.GetComponent<RectTransform>();
            RectTransform selectionEffectRect = rectTransform;

            // Get the world position of menuitem's RectTransform
            Vector3 menuItemWorldPos = menuItemRect.position;

            // Apply the y-offset if needed

            menuItemWorldPos.y += xOffsetValue;

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
                menuItem.DisableChildText();



            menuItem.GetComponent<SmoothTransitionMatValue>().enabled = false;


            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(false);
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
            }

            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(false);
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = false;
            }
        }

       

    }
}