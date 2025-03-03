using System.Collections;
using UnityEngine;

namespace IndieImpulseAssets
{
    public class MainMenuManagerWar : MainMenuManager
    {

        public MenuItemWar currentItem; // Currently hovered item
        public MenuItemWar lastHoveredItem; // Last hovered item before exiting
        public MenuItemWar[] menuItems;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        void Start()
        {
            // Find all MenuItem components in the child objects
            menuItems = GetComponentsInChildren<MenuItemWar>();


            // Hide SelectionEffect initially
            if (SelectionEffect != null && SelectionEffect2 != null)
            {
                SelectionEffect.SetActive(false);
            }



            // Set the first item as selected
            if (menuItems.Length > 0)
            {
                SetHover(menuItems[0]);
                if (SelectionEffect != null && SelectionEffect2 != null)
                    StartCoroutine(SetInitialSelectionPosition());


            }
        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItems[0], SelectionEffect.GetComponent<RectTransform>(), true);
            SetEffectRecTransform(menuItems[0], SelectionEffect2.GetComponent<RectTransform>(), false);

            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
            SelectionEffect2.SetActive(true);
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

        public void SetHover(MenuItemWar item, bool isarrowkey = false)
        {
            // If hovering over a different item, reset the last hovered item
            if (currentItem != null && currentItem != item)
            {
                currentItem.SetMaterial(normalFont);
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildText();

                SmoothTransitionMatValue smoothTransitionMatValue = currentItem.GetComponent<SmoothTransitionMatValue>();
                smoothTransitionMatValue.enabled = true;
                smoothTransitionMatValue.StartStepTransition();
                SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = true;
                SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = true;


                if (isarrowkey)
                {

                }

            }

            int currentIndex = System.Array.IndexOf(menuItems, currentItem);
            int newIndex = System.Array.IndexOf(menuItems, item);
            float scaleX = newIndex > currentIndex ? 1 : -1; // Right navigation is positive, left is negative

            // Set scale direction for selection effects
            UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();
            UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

            if (offsetMover1 != null) offsetMover1.SetScaleDirection(scaleX);
            if (offsetMover2 != null) offsetMover2.SetScaleDirection(scaleX);

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            item.EnableSmoothTransition();
            if (SelectionEffect != null && SelectionEffect2 != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true);
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), false);
            }


            if (isarrowkey)
            {

            }
            currentItem = item;
        }

        public void OnTextClicked(MenuItemWar item)
        {


            foreach (var menuitem in menuItems)
            {
                menuitem.SetMaterial(normalFont);
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildText();

                SmoothTransitionMatValue smoothTransitionMatValue = menuitem.GetComponent<SmoothTransitionMatValue>();
                smoothTransitionMatValue.enabled = true;
                smoothTransitionMatValue.StartStepTransition();
              
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



            int currentIndex = System.Array.IndexOf(menuItems, currentItem);
            int newIndex = System.Array.IndexOf(menuItems, item);
            float scaleX = newIndex > currentIndex ? 1 : -1; // Right navigation is positive, left is negative

            // Set scale direction for selection effects
            UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();
            UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

            if (offsetMover1 != null) offsetMover1.SetScaleDirection(scaleX);
            if (offsetMover2 != null) offsetMover2.SetScaleDirection(scaleX);

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            item.EnableSmoothTransition();
            if (SelectionEffect != null && SelectionEffect2 != null)
            {
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true);
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), false);
            }
            currentItem = item;

        }
        public void SetEffectRecTransform(MenuItemWar menuitem, RectTransform rectTransform, bool width)
        {
            // Get the RectTransform components
            RectTransform menuItemRect = menuitem.GetComponent<RectTransform>();
            RectTransform selectionEffectRect = rectTransform;

            // Get the world position of menuitem's RectTransform
            Vector3 menuItemWorldPos = menuItemRect.position;

            // Set the SelectionEffect's world position to match menuitem's world position
            selectionEffectRect.position = menuItemWorldPos;

            // Set the width of SelectionEffect to match menuitem's width
            if (width)
                selectionEffectRect.sizeDelta = new Vector2(menuItemRect.rect.width, selectionEffectRect.sizeDelta.y);



        }

        public void ResetHover(MenuItemWar item)
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
                float scaleX = direction > 0 ? 1 : -1; // Set scale direction based on navigation
                SetHover(menuItems[nextIndex], true);

                // Set scale direction in UIOffsetMover for both SelectionEffects
                UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();
                UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

                if (offsetMover1 != null) offsetMover1.SetScaleDirection(scaleX);
                if (offsetMover2 != null) offsetMover2.SetScaleDirection(scaleX);

                offsetMover1.enabled = true;
                offsetMover2.enabled = true;
            }
        }

    }
}