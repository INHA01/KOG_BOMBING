using System;
using System.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class MainMenuManagerAdventure : MainMenuManager
    {

        public MenuItemAdventure currentItem; // Currently hovered item
        public MenuItemAdventure lastHoveredItem; // Last hovered item before exiting
        public MenuItemAdventure[] menuItems;
        public GameObject SelectionEffect;
        public float selectionEffectOffsetY;

        void Start()
        {
            // Find all MenuItem components in the child objects
            menuItems = GetComponentsInChildren<MenuItemAdventure>();


            // Hide SelectionEffect initially
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(false);
            }

            // Set the first item as selected
            if (menuItems.Length > 0)
            {
                SetHover(menuItems[0]);
                if (SelectionEffect != null)
                    StartCoroutine(SetInitialSelectionPosition());

            }
        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItems[0], SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);


        }

        void Update()
        {
            // Navigate with arrow keys
            if (Input.GetKeyDown(KeyCode.UpArrow))
            {
                SelectNextItem(-1);
            }
            else if (Input.GetKeyDown(KeyCode.DownArrow))
            {
                SelectNextItem(1);
            }
        }

        public void SetHover(MenuItemAdventure item, bool isarrowkey = false)
        {
            SmoothTransitionMatValue[] smoothTransitionMatValues;
            TextGradientAlphaController textGradientAlphaController;

            // If hovering over a different item, reset the last hovered item
            if (currentItem != null && currentItem != item)
            {
                currentItem.SetMaterial(normalFont);
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildText();



                smoothTransitionMatValues = currentItem.GetComponents<SmoothTransitionMatValue>();
                if (smoothTransitionMatValues.Length >= 2)
                {
                    smoothTransitionMatValues[0].enabled = false;
                    smoothTransitionMatValues[1].enabled = false;
                }

                textGradientAlphaController = currentItem.GetComponent<TextGradientAlphaController>();
                textGradientAlphaController.enabled = false;


                if (SelectionEffect != null)
                {
                    SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                    SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                }


                if (isarrowkey)
                {

                }

            }



            smoothTransitionMatValues = item.GetComponents<SmoothTransitionMatValue>();
            if (smoothTransitionMatValues.Length >= 2)
            {
                smoothTransitionMatValues[0].enabled = true;
                smoothTransitionMatValues[1].enabled = true;
            }



            textGradientAlphaController = item.GetComponent<TextGradientAlphaController>();
            textGradientAlphaController.enabled = true;


            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

            }


            if (isarrowkey)
            {

            }
            currentItem = item;
        }


        public void OnTextClicked(MenuItemAdventure item)
        {



            SmoothTransitionMatValue[] smoothTransitionMatValues;
            TextGradientAlphaController textGradientAlphaController;

            foreach (var menuitem in menuItems)
            {
                menuitem.SetMaterial(normalFont);
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildText();



                smoothTransitionMatValues = menuitem.GetComponents<SmoothTransitionMatValue>();
                if (smoothTransitionMatValues.Length >= 2)
                {
                    smoothTransitionMatValues[0].enabled = false;
                    smoothTransitionMatValues[1].enabled = false;
                }

                textGradientAlphaController = menuitem.GetComponent<TextGradientAlphaController>();
                textGradientAlphaController.enabled = false;
            }
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(true);
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }





            smoothTransitionMatValues = item.GetComponents<SmoothTransitionMatValue>();
            if (smoothTransitionMatValues.Length >= 2)
            {
                smoothTransitionMatValues[0].enabled = true;
                smoothTransitionMatValues[1].enabled = true;
            }

            textGradientAlphaController = item.GetComponent<TextGradientAlphaController>();
            textGradientAlphaController.enabled = true;



            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

        }

        public void SetEffectRecTransform(MenuItemAdventure menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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


        public void ResetHover(MenuItemAdventure item)
        {
            // Only reset the hover state if the new item is different
            if (currentItem == item)
            {
                lastHoveredItem = currentItem; // Remember the last hovered item
            }
            else if (lastHoveredItem != null && lastHoveredItem != currentItem)
            {
                lastHoveredItem.SetMaterial(normalFont);

            }
        }

        private void SelectNextItem(int direction)
        {
            int currentIndex = System.Array.IndexOf(menuItems, currentItem);
            int nextIndex = Mathf.Clamp(currentIndex + direction, 0, menuItems.Length - 1);



            if (nextIndex != currentIndex)
            {
                SetHover(menuItems[nextIndex], true);

                UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();

                offsetMover1.enabled = true;

            }
        }

    }
}