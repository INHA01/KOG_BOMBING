using IndieImpulseAssets;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace IndieImpulseAssets
{
    public class FightingTextEffectSingle : MainMenuManager
    {
        public MenuItemFightingSingle menuItem; // Single menu item
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public float selectionEffectOffsetY;
        public float selectionEffect2OffsetY;
        private SmoothTransitionMatValue smoothTransitionMatValue;
        private TextHitWallAnimation textHitWallAnimation;

        void Start()
        {
            // Hide SelectionEffect initially
            if (SelectionEffect != null)
                SelectionEffect.SetActive(false);

            if (SelectionEffect2 != null)
                SelectionEffect2.SetActive(false);

            // Initialize the single item hover
            hoverFont.material.SetFloat(transform.GetChild(0).GetComponent<SmoothTransitionMatValue>().MatValue, transform.GetChild(0).GetComponent<SmoothTransitionMatValue>().endStep);

        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for SelectionEffect
            if (SelectionEffect != null)
            {
                SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);
                SelectionEffect.SetActive(true);
            }

            if (SelectionEffect2 != null)
            {
                SetEffectRecTransform(menuItem, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffect2OffsetY);
                SelectionEffect2.SetActive(true);
            }
        }

        public void SetHover(MenuItemFightingSingle item)
        {
            // Enable hover effects
            smoothTransitionMatValue = item.GetComponent<SmoothTransitionMatValue>();
            textHitWallAnimation = item.GetComponent<TextHitWallAnimation>();

            if (smoothTransitionMatValue != null) { smoothTransitionMatValue.enabled = false; smoothTransitionMatValue.enabled = true; }
            smoothTransitionMatValue.enabled = true;

            if (textHitWallAnimation != null) { textHitWallAnimation.enabled = false; textHitWallAnimation.enabled = true; }


            item.SetMaterial(hoverFont);
            item.EnableChildText();

            // Adjust selection effects
            if (SelectionEffect != null)
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), false, selectionEffectOffsetY);

            if (SelectionEffect2 != null)
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), true, selectionEffect2OffsetY);


            SelectionEffect.SetActive(true);
            SelectionEffect.GetComponent<Image>().enabled = true;
            UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();

            offsetMover1.enabled = true;

            SelectionEffect2.SetActive(true);
            UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

            offsetMover2.enabled = true;
        }

        public void ResetHover()
        {
            // Reset hover effects
            if (menuItem != null)
            {
                menuItem.SetMaterial(normalFont);
                menuItem.DisableChildText();

                if (smoothTransitionMatValue != null)
                    smoothTransitionMatValue.enabled = false;

                if (textHitWallAnimation != null)
                    textHitWallAnimation.enabled = false;
            }
        }

        private void SetEffectRecTransform(MenuItemFightingSingle menuitem, RectTransform rectTransform, bool adjustWidth, float yOffsetValue)
        {
            // Get the RectTransform of the menu item
            RectTransform menuItemRect = menuitem.GetComponent<RectTransform>();

            // Set position with offset
            Vector3 menuItemWorldPos = menuItemRect.position;
            menuItemWorldPos.y += yOffsetValue;
            rectTransform.position = menuItemWorldPos;

            // Optionally adjust width
            if (adjustWidth)
                rectTransform.sizeDelta = new Vector2(menuItemRect.rect.width, rectTransform.sizeDelta.y);
        }
    }
}