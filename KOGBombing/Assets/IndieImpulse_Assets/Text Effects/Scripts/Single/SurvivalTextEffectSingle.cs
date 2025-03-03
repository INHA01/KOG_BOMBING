using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class SurvivalTextEffectSingle : MainMenuManager
    {

        public MenuItemSurvivalSingle menuItem;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public float selectionEffectOffsetY;
        void Start()
        {
           

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
            SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);
            SetEffectRecTransform(menuItem, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
            SelectionEffect2.SetActive(true);
        }

        public void SetHover(MenuItemSurvivalSingle item, bool isarrowkey = false)
        {
            SmoothTransitionMatValue smoothTransitionMatValue;
            SurvivalTextAnimation survivalTextAnimation;
         
            smoothTransitionMatValue = item.GetComponent<SmoothTransitionMatValue>();
            smoothTransitionMatValue.enabled = false;
            smoothTransitionMatValue.enabled = true;


            survivalTextAnimation = item.GetComponent<SurvivalTextAnimation>();
            survivalTextAnimation.enabled = false;
            survivalTextAnimation.enabled = true;

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(true);
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;

                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            }

            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(true);
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = true;

                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            }


        }

        public void SetEffectRecTransform(MenuItemSurvivalSingle menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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
                menuItem.DisableChildText();


             menuItem.GetComponent<SmoothTransitionMatValue>().enabled = false;

            menuItem.GetComponent<SurvivalTextAnimation>().enabled = false;

            SelectionEffect.SetActive(false);   
            SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;

            SelectionEffect2.SetActive(false);
            SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = false;

        }

    }
}