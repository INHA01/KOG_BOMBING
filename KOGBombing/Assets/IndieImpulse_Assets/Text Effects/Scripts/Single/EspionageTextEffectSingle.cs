using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class EspionageTextEffectSingle : MainMenuManager
    {

        public MenuItemEspionageSingle menuItem;
        public GameObject SelectionEffect;
        public float selectionEffectOffsetY;
        void Start()
        {
            // Find all MenuItem components in the child objects


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
            SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);

        }

      

        public void SetHover(MenuItemEspionageSingle item, bool isarrowkey = false)
        {

            EspionageTextEffect espionageTextEffect;

            espionageTextEffect = item.GetComponent<EspionageTextEffect>();

            espionageTextEffect.enabled = false;
            espionageTextEffect.enabled = true;
            SelectionEffect.SetActive(true);

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

        }

        public void SetEffectRecTransform(MenuItemEspionageSingle menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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

            SelectionEffect.SetActive(false);   
            menuItem.GetComponent<EspionageTextEffect>().enabled = false; 

        }

       

    }
}