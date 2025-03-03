using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class AdventureTextEffectSingle : MainMenuManager
    {


        public MenuItemAdventureSingle menuItem;
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

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);


        }


        public void SetHover(MenuItemAdventureSingle item, bool isarrowkey = false)
        {
            SmoothTransitionMatValue[] smoothTransitionMatValues;
            TextGradientAlphaController textGradientAlphaController;

            item.SetMaterial(hoverFont);




            smoothTransitionMatValues = item.GetComponents<SmoothTransitionMatValue>();
            if (smoothTransitionMatValues.Length >= 2)
            {
                smoothTransitionMatValues[0].enabled = false;
                smoothTransitionMatValues[1].enabled = false;
            }

            textGradientAlphaController = item.GetComponent<TextGradientAlphaController>();
            textGradientAlphaController.enabled = false;


            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(true);
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }




            if (smoothTransitionMatValues.Length >= 2)
            {
                smoothTransitionMatValues[0].enabled = true;
                smoothTransitionMatValues[1].enabled = true;
            }



            textGradientAlphaController = item.GetComponent<TextGradientAlphaController>();
            textGradientAlphaController.enabled = true;


            // Set the material of the new item
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            }



        }

        public void SetEffectRecTransform(MenuItemAdventureSingle menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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
            // Only reset the hover state if the new item is different
            if (menuItem != null)

                menuItem.SetMaterial(normalFont);
            SelectionEffect.SetActive(false);   

        }
    }



}
