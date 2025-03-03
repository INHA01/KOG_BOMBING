using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class TextShadowEffect : MonoBehaviour
    {
        private TextMeshProUGUI shadowText;
        public float disableDelay = 1f;
        private Coroutine disableCoroutine;
        // Animation settings
        public float duration = 1.0f;
        public Vector2 shadowOffsetRange = new Vector2(-50f, 50f);
        public Vector2 skewAmount = new Vector2(-0.1f, 0.05f); // Skew for floor projection look

        private Vector2 initialPosition;
        private float timer;
        private bool isAnimating;

        void Start()
        {
            // Initialize shadowText and set the initial position only once
            shadowText = GetComponent<TextMeshProUGUI>();
            if (shadowText != null)
            {
                initialPosition = shadowText.rectTransform.anchoredPosition;
            }
            // Reset shadow position to start from the leftmost position
            shadowText.rectTransform.anchoredPosition = initialPosition + new Vector2(shadowOffsetRange.x, 0);
            ApplySkewEffect();

            timer = 0f;
            isAnimating = true;
        }

        void OnEnable()
        {
            // Reset animation on enable
            if (shadowText != null)
            {
                // Reset shadow position to start from the leftmost position
                shadowText.rectTransform.anchoredPosition = initialPosition + new Vector2(shadowOffsetRange.x, 0);
                ApplySkewEffect();

                timer = 0f;
                isAnimating = true;
            }
            disableCoroutine = StartCoroutine(DisableAfterDelay());
        }
        private IEnumerator DisableAfterDelay()
        {
            yield return new WaitForSeconds(disableDelay);
            gameObject.SetActive(false);
        }

        void OnDisable()
        {
            // Stop the disable coroutine if it's running
            if (disableCoroutine != null)
            {
                StopCoroutine(disableCoroutine);
                disableCoroutine = null;
            }
        }

        void Update()
        {
            if (isAnimating && shadowText != null)
            {
                // Increment timer based on the animation duration
                timer += Time.deltaTime / duration;

                // Calculate shadow movement from left to right
                float xOffset = Mathf.Lerp(shadowOffsetRange.x, shadowOffsetRange.y, timer);
                shadowText.rectTransform.anchoredPosition = new Vector2(initialPosition.x + xOffset, initialPosition.y);

                // Stop animation when complete
                if (timer >= 1f)
                {
                    isAnimating = false;
                }
            }
        }

        void ApplySkewEffect()
        {
            // Apply skew for a floor-like shadow effect
            shadowText.rectTransform.localScale = new Vector3(1, 0.5f, 1); // Flatten vertically
            shadowText.rectTransform.pivot = new Vector2(0.5f, 1); // Set pivot to the top center for skew effect
            shadowText.rectTransform.localRotation = Quaternion.Euler(skewAmount.x * 90, skewAmount.y * 90, 0);
        }
    }
}