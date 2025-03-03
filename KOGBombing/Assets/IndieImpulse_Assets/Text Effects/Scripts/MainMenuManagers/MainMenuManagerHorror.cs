using System.Collections;
using UnityEngine;

namespace IndieImpulseAssets
{
    public class MainMenuManagerHorror : MainMenuManager
    {

        public MenuItemHorror currentItem; // Currently hovered item
        public MenuItemHorror lastHoveredItem; // Last hovered item before exiting
        public MenuItemHorror[] menuItems;
        public GameObject SelectionEffect;
        public float EffectoffsetY; // Offset value for Y-axis
        void Start()
        {
            // Find all MenuItem components in the child objects
            menuItems = GetComponentsInChildren<MenuItemHorror>();

           
            // Hide SelectionEffect initially
            if (SelectionEffect != null)
                SelectionEffect.SetActive(false);

            // Set the first item as selected
            if (menuItems.Length > 0)
            {
                SetHover(menuItems[0]);
                if (SelectionEffect != null)
                    StartCoroutine(SetInitialSelectionPosition());
            }

            foreach (MenuItemHorror _item in menuItems)
            {

                if (OnClick)
                {
                    _item.GetComponent<GlitchTextEffect>().Onclick = true;
                    _item.transform.GetChild(0).GetComponent<GlitchTextEffect>().Onclick = true;
                }
                else
                {
                    _item.GetComponent<GlitchTextEffect>().Onclick = false;
                    _item.transform.GetChild(0).GetComponent<GlitchTextEffect>().Onclick = false;
                }
            }
        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransformOffset(menuItems[0]);

            // Show the SelectionEffect after positioning
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

        public void SetHover(MenuItemHorror item, bool isarrowkey = false)
        {
            // If hovering over a different item, reset the last hovered item
            if (currentItem != null && currentItem != item)
            {
                currentItem.SetMaterial(normalFont);
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildText();
                if (currentItem.transform.childCount > 0)
                    currentItem.DisableChildGlitchEffect();
                currentItem.DisablePingPongEffect();
                if (isarrowkey)
                {
                    if (currentItem.transform.childCount > 0)
                        currentItem.DisableChildGlitchTextEffect();
                }

            }

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (item.transform.childCount > 0)
                item.EnableChildGlitchEffect();
            item.EnablePingPongEffect();
            if (SelectionEffect != null)
                SetEffectRecTransformOffset(item);
            item.GetComponent<GlitchTextEffect>().Onclick = false;

            if (isarrowkey)
            {
                if (item.transform.childCount > 0)
                    item.EnableChildGlitchTextEffect();
            }
            currentItem = item;
        }


        public void OnTextClicked(MenuItemHorror item)
        {

            foreach (var menuitem in menuItems)
            {
                menuitem.SetMaterial(normalFont);
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildText();
                if (menuitem.transform.childCount > 0)
                    menuitem.DisableChildGlitchEffect();
                menuitem.DisablePingPongEffect();
            }

            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            if (item.transform.childCount > 0)
                item.EnableChildGlitchEffect();
            item.EnablePingPongEffect();
            if (SelectionEffect != null)
                SetEffectRecTransformOffset(item);
            item.GetComponent<GlitchTextEffect>().Onclick = true;
            
        }

        public void SetEffectRecTransformOffset(MenuItemHorror menuitem)
        {
            Vector2 newPosition = SelectionEffect.GetComponent<RectTransform>().anchoredPosition;

            // Set the Y position to match the reference's Y position with an offset
            newPosition.y = menuitem.GetComponent<RectTransform>().anchoredPosition.y + EffectoffsetY;

            // Apply the new position while keeping the X position unchanged
            SelectionEffect.GetComponent<RectTransform>().anchoredPosition = newPosition;

        }

        public void ResetHover(MenuItemHorror item)
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
            // Get the index of the current item in the array
            int currentIndex = System.Array.IndexOf(menuItems, currentItem);
            int nextIndex = Mathf.Clamp(currentIndex + direction, 0, menuItems.Length - 1);

            if (nextIndex != currentIndex)
            {
                SetHover(menuItems[nextIndex], true);
            }
        }
    }
}