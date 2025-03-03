using UnityEngine;
using TMPro;

namespace IndieImpulseAssets
{
    public class EspionageTextEffect : MonoBehaviour
    {
        public TextMeshProUGUI textComponent;
        public float flickerDuration = 0.05f;   // Duration for each flicker effect
        public float revealInterval = 0.1f;     // Interval for each character reveal
        public float maxScaleOffset = 0.05f;    // Max scale variation for subtle pulsation

        private Vector3 initialScale;       // Store the initial scale
        private Color initialColor;         // Store the initial color
        private string initialText;         // Store the initial text content
        private int initialTextCharCout;
        private Coroutine espionageCoroutine;
        private bool isAnimating = false;

        void Awake()
        {
            if (textComponent == null)
                textComponent = GetComponent<TextMeshProUGUI>();

            // Store initial values
            initialScale = textComponent.rectTransform.localScale;
            initialColor = textComponent.color;
            initialText = textComponent.text;
            initialTextCharCout = textComponent.maxVisibleCharacters;
        }

        void OnEnable()
        {
            // Reset to initial state when enabled
            ResetToInitialState();

            // Start the animation
            espionageCoroutine = StartCoroutine(EspionageEffect());
        }

        void OnDisable()
        {
            // Stop any running animation coroutine
            if (espionageCoroutine != null)
            {
                StopCoroutine(espionageCoroutine);
                espionageCoroutine = null;
            }

            // Reset the animation flag and text properties to initial state
            isAnimating = false;
            ResetToInitialState();
        }

        private void ResetToInitialState()
        {
            // Reset the text properties to their initial values
            textComponent.rectTransform.localScale = initialScale;
            textComponent.color = initialColor;
            textComponent.text = initialText;
            textComponent.maxVisibleCharacters = initialTextCharCout;
        }

        private System.Collections.IEnumerator EspionageEffect()
        {
            if (isAnimating) yield break;
            isAnimating = true;

            // Reveal text character by character
            for (int i = 0; i < initialText.Length; i++)
            {
                textComponent.maxVisibleCharacters = i + 1;

                // Flicker effect on each reveal
                yield return StartCoroutine(FlickerEffect());

                // Apply subtle scale pulsation
                Vector3 randomScale = initialScale + new Vector3(
                    Random.Range(-maxScaleOffset, maxScaleOffset),
                    Random.Range(-maxScaleOffset, maxScaleOffset),
                    0
                );
                textComponent.rectTransform.localScale = randomScale;

                // Wait before revealing the next character
                yield return new WaitForSeconds(revealInterval);

                // Reset scale after each reveal step
                textComponent.rectTransform.localScale = initialScale;
            }

            // Ensure full text is visible after animation
            textComponent.maxVisibleCharacters = initialText.Length;
            isAnimating = false;
        }

        private System.Collections.IEnumerator FlickerEffect()
        {
            // Temporary flicker effect
            Color flickerColor = new Color(initialColor.r, initialColor.g, initialColor.b, 0.5f);
            textComponent.color = flickerColor;
            yield return new WaitForSeconds(flickerDuration);

            // Restore original color
            textComponent.color = initialColor;
        }
    }
}