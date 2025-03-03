using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class MainMenuManagerFighting : MainMenuManager
    {
        public MenuItemFighting currentItem; // Currently hovered item
        public MenuItemFighting lastHoveredItem; // Last hovered item before exiting
        public MenuItemFighting[] menuItems;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public float selectionEffectOffsetY;
        public float selectionEffect2OffsetY;
        void Start()
        {
            // Find all MenuItem components in the child objects
            menuItems = GetComponentsInChildren<MenuItemFighting>();


            // Hide SelectionEffect initially
            if (SelectionEffect != null)
            {
                SelectionEffect.SetActive(false);
            }
            if (SelectionEffect2 != null)
            {
                SelectionEffect2.SetActive(false);
            }


            // Set the first item as selected
            if (menuItems.Length > 0)
            {
                SetHover(menuItems[0]);
                if (SelectionEffect != null)
                    StartCoroutine(SetInitialSelectionPosition());

                if (SelectionEffect2 != null)
                    StartCoroutine(SetInitialSelectionPosition());

            }
        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItems[0], SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);
            SetEffectRecTransform(menuItems[0], SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffect2OffsetY);

            if (SelectionEffect != null)
                SelectionEffect.SetActive(true);

            if (SelectionEffect2 != null)
                SelectionEffect2.SetActive(true);
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

        public void SetHover(MenuItemFighting item, bool isarrowkey = false)
        {
            SmoothTransitionMatValue smoothTransitionMatValue;

            TextHitWallAnimation textHitWallAnimation;

            // If hovering over a different item, reset the last hovered item
            if (currentItem != null && currentItem != item)
            {
                currentItem.SetMaterial(normalFont);
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildText();



                smoothTransitionMatValue = currentItem.GetComponent<SmoothTransitionMatValue>();

                smoothTransitionMatValue.enabled = false;

                textHitWallAnimation = currentItem.GetComponent<TextHitWallAnimation>();

                textHitWallAnimation.enabled = false;



                if (SelectionEffect != null)
                {
                    SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                    SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                }

                if (SelectionEffect2 != null)
                {
                    SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                    SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                }
                if (isarrowkey)
                {

                }

            }


            smoothTransitionMatValue = item.GetComponent<SmoothTransitionMatValue>();

            smoothTransitionMatValue.enabled = true;


            textHitWallAnimation = item.GetComponent<TextHitWallAnimation>();

            textHitWallAnimation.enabled = true;


            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

            if (SelectionEffect2 != null)
            {
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffect2OffsetY);

            }


            if (isarrowkey)
            {

            }
            currentItem = item;
        }
        public void OnTextClicked(MenuItemFighting item) 
        {

            SmoothTransitionMatValue smoothTransitionMatValue;

            TextHitWallAnimation textHitWallAnimation;

            foreach (var menuitem in menuItems)
            {
                menuitem.SetMaterial(normalFont);
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildText();



                smoothTransitionMatValue = menuitem.GetComponent<SmoothTransitionMatValue>();

                smoothTransitionMatValue.enabled = false;

                textHitWallAnimation = menuitem.GetComponent<TextHitWallAnimation>();

                textHitWallAnimation.enabled = false;
            }
            if (SelectionEffect != null)
            {
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }

            if (SelectionEffect2 != null)
            {
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = false;
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = true;
            }
           


            smoothTransitionMatValue = item.GetComponent<SmoothTransitionMatValue>();

            smoothTransitionMatValue.enabled = true;


            textHitWallAnimation = item.GetComponent<TextHitWallAnimation>();

            textHitWallAnimation.enabled = true;


            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            }

            if (SelectionEffect2 != null)
            {
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffect2OffsetY);

            }


        }
        public void SetEffectRecTransform(MenuItemFighting menuitem, RectTransform rectTransform, bool width, float yOffsetValue)
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


        public void ResetHover(MenuItemFighting item)
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

                UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

                offsetMover2.enabled = true;

            }
        }

    }
}