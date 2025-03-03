using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class MainMenuManagerFantasy : MainMenuManager
    {

        public MenuItemFantasy currentItem; // Currently hovered item
        public MenuItemFantasy lastHoveredItem; // Last hovered item before exiting
        public MenuItemFantasy[] menuItems;
        public GameObject SelectionEffect;
        public float selectionEffectOffsetY;
        void Start()
        {
            // Find all MenuItem components in the child objects
            menuItems = GetComponentsInChildren<MenuItemFantasy>();


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


            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
        }

        void Update()
        {
            // Navigate with arrow keys
            if (Input.GetKeyDown(KeyCode.LeftArrow))
            {
                SelectNextItem(-1);
            }
            else if (Input.GetKeyDown(KeyCode.RightArrow))
            {
                SelectNextItem(1);
            }
        }

        public void SetHover(MenuItemFantasy item, bool isarrowkey = false)
        {
            SmoothTransitionMatColor smoothTransitionMatColor;
            // If hovering over a different item, reset the last hovered item
            if (currentItem != null && currentItem != item)
            {
                currentItem.SetMaterial(normalFont);
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildText();


                smoothTransitionMatColor = currentItem.GetComponent<SmoothTransitionMatColor>();
                smoothTransitionMatColor.enabled = false;

                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;

                SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = true;

                if (isarrowkey)
                {

                }

            }


            smoothTransitionMatColor = item.GetComponent<SmoothTransitionMatColor>();
            smoothTransitionMatColor.enabled = true;

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

        public void SetEffectRecTransform(MenuItemFantasy menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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


        public void ResetHover(MenuItemFantasy item)
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


        public void OnTextClicked(MenuItemFantasy item)
        {

            SmoothTransitionMatColor smoothTransitionMatColor;

            foreach (var menuitem in menuItems)
            {
                menuitem.SetMaterial(hoverFont);
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildText();


                smoothTransitionMatColor = menuitem.GetComponent<SmoothTransitionMatColor>();
                smoothTransitionMatColor.enabled = false;

                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;

                SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = true;

               
            }
            if (SelectionEffect != null)
            {
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }

            smoothTransitionMatColor = item.GetComponent<SmoothTransitionMatColor>();
            smoothTransitionMatColor.enabled = true;

            // Set the material of the new item
            item.SetMaterial(normalFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true, selectionEffectOffsetY);

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
                offsetMover1.transform.GetChild(0).GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }
        }

    }
}