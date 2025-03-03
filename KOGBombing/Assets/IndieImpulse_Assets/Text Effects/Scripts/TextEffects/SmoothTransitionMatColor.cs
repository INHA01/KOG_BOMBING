using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class SmoothTransitionMatColor : MonoBehaviour
    {
        public TextMeshProUGUI textMeshPro; // Assign in Inspector
        public MainMenuManager mainMenuManager;
        private Material textMaterial;
        private Color originalFaceColor;
        public float minIntensity = 2.3f;
        public float maxIntensity = 3.3f;
        public float duration = 1.0f; // Duration for the transition

        private Coroutine transitionCoroutine;

        private void OnEnable()
        {
            // Get the material from MainMenuManager if not already assigned
            if (textMeshPro != null && mainMenuManager != null)
            {
                if (textMaterial == null)
                {
                    textMaterial = mainMenuManager.hoverFont.material;
                }

                // Store the original face color if not already stored
                originalFaceColor = textMaterial.GetColor("_FaceColor");

                // Start the intensity cycle
                StartTransition();
            }
        }

        private void OnDisable()
        {
            // Stop the coroutine to reset if disabled
            if (transitionCoroutine != null)
            {
                StopCoroutine(transitionCoroutine);
                transitionCoroutine = null;
            }

            // Reset the color to the original face color
            if (textMaterial != null)
            {
                textMaterial.SetColor("_FaceColor", originalFaceColor);
            }
        }

        public void StartTransition()
        {
            // Stop any previous coroutine before starting a new one
            if (transitionCoroutine != null)
            {
                StopCoroutine(transitionCoroutine);
            }
            transitionCoroutine = StartCoroutine(LerpIntensity(minIntensity, maxIntensity));
        }

        private IEnumerator LerpIntensity(float startIntensity, float endIntensity)
        {
            float elapsed = 0.0f;

            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = Mathf.Clamp01(elapsed / duration);
                float intensity = Mathf.Lerp(startIntensity, endIntensity, t);

                // Create a new color with HDR intensity
                Color hdrColor = originalFaceColor * intensity;

                // Set the HDR face color
                textMaterial.SetColor("_FaceColor", hdrColor);

                yield return null;
            }

            // Ensure the final color is set to avoid abrupt changes
            textMaterial.SetColor("_FaceColor", originalFaceColor * endIntensity);
        }
    }
}