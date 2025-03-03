using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

namespace IndieImpulseAssets
{
    public class WarTextEffectSingle : MainMenuManager
    {

        public MenuItemWarSingle menuItem;
        public GameObject SelectionEffect;
        public GameObject SelectionEffect2;
        public bool Left;
        void Start()
        {

            // Hide SelectionEffect initially
            if (SelectionEffect != null && SelectionEffect2 != null)
            {
                SelectionEffect.SetActive(false);
            }

        }

        private IEnumerator SetInitialSelectionPosition()
        {
            // Wait until the end of the frame to ensure layout is updated
            yield return new WaitForEndOfFrame();

            // Set the initial position for the SelectionEffect
            SetEffectRecTransform(menuItem, SelectionEffect.GetComponent<RectTransform>(), true);
            SetEffectRecTransform(menuItem, SelectionEffect2.GetComponent<RectTransform>(), false);

            // Show the SelectionEffect after positioning
            SelectionEffect.SetActive(true);
            SelectionEffect2.SetActive(true);
        }


        public void SetHover(MenuItemWarSingle item, bool isarrowkey = false)
        {



            // Set scale direction for selection effects
            UISmoothTransitionMatValue offsetMover1 = SelectionEffect.GetComponent<UISmoothTransitionMatValue>();
            UISmoothTransitionMatValue offsetMover2 = SelectionEffect2.GetComponent<UISmoothTransitionMatValue>();

            if (offsetMover1 != null)
            {
                offsetMover1.enabled = true;

                if (Left)
                {
                    offsetMover1.SetScaleDirection(-1f);
                }
                else
                {
                    offsetMover1.SetScaleDirection(1);
                }
            }


            if (offsetMover2 != null)
            {
                offsetMover2.enabled = true;
                if (Left)
                {
                    offsetMover2.SetScaleDirection(-1f);
                }
                else
                {
                    offsetMover2.SetScaleDirection(1);
                }
            }



            // Set the material of the new item
            item.SetMaterial(hoverFont);
            item.EnableChildText();
            item.EnableSmoothTransition();
            if (SelectionEffect != null && SelectionEffect2 != null)
            {
                SelectionEffect.SetActive(true);
                SetEffectRecTransform(item, SelectionEffect.GetComponent<RectTransform>(), true);
                SelectionEffect2.SetActive(true);
                SetEffectRecTransform(item, SelectionEffect2.GetComponent<RectTransform>(), false);
            }

        }

        public void SetEffectRecTransform(MenuItemWarSingle menuitem, RectTransform rectTransform, bool width)
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

        public void ResetHover()
        {
            menuItem.SetMaterial(normalFont);
            if (menuItem.transform.childCount > 0)
                menuItem.DisableChildText();

            SmoothTransitionMatValue smoothTransitionMatValue = menuItem.GetComponent<SmoothTransitionMatValue>();
            smoothTransitionMatValue.enabled = true;
            smoothTransitionMatValue.StartStepTransition();

            SelectionEffect.SetActive(false);
            SelectionEffect.GetComponent<UISmoothTransitionMatValue>().enabled = false;
            SelectionEffect2.SetActive(false);
            SelectionEffect2.GetComponent<UISmoothTransitionMatValue>().enabled = false;
        }

    }
}