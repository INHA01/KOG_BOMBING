using UnityEngine;

namespace IndieImpulseAssets
{
    public class CyberpunkText : MonoBehaviour
    {
        public RectTransform rectTransform;
        public float glitchDuration = 0.1f;  // Duration for each glitch movement
        public float glitchInterval = 0.3f;  // Interval between glitch effects
        public float maxPositionOffset = 10f; // Max pixel movement offset
        public float maxScaleOffset = 0.1f;   // Max scale variation for the pulsation effect

        private Vector2 originalPosition;
        private Vector3 originalScale;
        private float glitchTimer = 0f;

        void Start()
        {
            if (rectTransform == null)
                rectTransform = GetComponent<RectTransform>();

            // Store the original position and scale of the RectTransform
            originalPosition = rectTransform.anchoredPosition;
            originalScale = rectTransform.localScale;
        }

        void Update()
        {
            glitchTimer += Time.deltaTime;

            // Trigger the glitch effect at intervals
            if (glitchTimer >= glitchInterval)
            {
                StartCoroutine(ApplyGlitchEffect());
                glitchTimer = 0f;
            }
        }

        private System.Collections.IEnumerator ApplyGlitchEffect()
        {
            // Phase 1: Random position offset
            Vector2 randomPosition = originalPosition + new Vector2(
                Random.Range(-maxPositionOffset, maxPositionOffset),
                Random.Range(-maxPositionOffset, maxPositionOffset)
            );
            rectTransform.anchoredPosition = randomPosition;

            // Phase 2: Random scale pulsation
            Vector3 randomScale = originalScale + new Vector3(
                Random.Range(-maxScaleOffset, maxScaleOffset),
                Random.Range(-maxScaleOffset, maxScaleOffset),
                0
            );
            rectTransform.localScale = randomScale;

            // Hold the glitch effect briefly
            yield return new WaitForSeconds(glitchDuration);

            // Reset to the original position and scale
            rectTransform.anchoredPosition = originalPosition;
            rectTransform.localScale = originalScale;
        }
    }
}