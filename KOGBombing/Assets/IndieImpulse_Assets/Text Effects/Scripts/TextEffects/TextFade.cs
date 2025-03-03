using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class TextFade : MonoBehaviour
    {
        public TextMeshProUGUI textComponent;
        public bool fadeIn = true;          // Set to true for fade-in, false for fade-out
        public float fadeDuration = 1f;     // Duration of the fade effect

        private Coroutine fadeCoroutine;

        private void Awake()
        {
            if (textComponent == null)
            {
                Debug.LogError("Text Component is not assigned in the Inspector.");
                return;
            }
        }

        private void OnEnable()
        {
            StartFade();
        }

        private void OnDisable()
        {
            if (fadeCoroutine != null)
            {
                StopCoroutine(fadeCoroutine);
                fadeCoroutine = null;
            }
        }

        public void StartFade()
        {
            if (fadeCoroutine != null)
            {
                StopCoroutine(fadeCoroutine);
            }

            fadeCoroutine = StartCoroutine(Fade());
        }

        private IEnumerator Fade()
        {
            float startAlpha = fadeIn ? 0f : 1f;
            float endAlpha = fadeIn ? 1f : 0f;
            float elapsed = 0f;

            // Set the initial alpha
            Color color = textComponent.color;
            color.a = startAlpha;
            textComponent.color = color;

            while (elapsed < fadeDuration)
            {
                elapsed += Time.deltaTime;
                float alpha = Mathf.Lerp(startAlpha, endAlpha, elapsed / fadeDuration);
                color.a = alpha;
                textComponent.color = color;

                yield return null;
            }

            // Ensure the final alpha is set correctly
            color.a = endAlpha;
            textComponent.color = color;

            // Disable the script after the fade is complete
            enabled = false;
        }
    }
}