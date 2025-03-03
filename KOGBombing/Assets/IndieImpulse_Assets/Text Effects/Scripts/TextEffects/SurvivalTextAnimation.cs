using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class SurvivalTextAnimation : MonoBehaviour
    {
        public TextMeshProUGUI textComponent;
        public float pulseSpeed = 1f;       // Speed of the pulsing
        public float maxScale = 1.1f;       // Max scale for the pulsing effect
        public float jitterAmount = 2f;     // Maximum pixel offset for jitter
        public float jitterSpeed = 10f;     // Speed of jitter effect
        public float animationDuration = 2f; // Duration for the animation to run

        private Vector3 initialScale;
        private Vector3 initialPosition;

        private Coroutine animationCoroutine;

        private void Awake()
        {
            initialScale = textComponent.transform.localScale;
            initialPosition = textComponent.transform.localPosition;
        }

        private void OnEnable()
        {
            StartStepAnimateText();
        }

        private void OnDisable()
        {
            // Stop the coroutine to reset if disabled
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
                animationCoroutine = null;
            }
            // Reset to the initial state when disabled
            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;
        }

        public void StartStepAnimateText()
        {
            // Stop any previous coroutine before starting a new one
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
            }

            // Reset the initial scale and position before starting the animation
            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;

            animationCoroutine = StartCoroutine(AnimateText());
        }

        private IEnumerator AnimateText()
        {
            float elapsedTime = 0f;

            while (elapsedTime < animationDuration)
            {
                // Pulsing effect
                float scale = 1 + Mathf.Sin(Time.time * pulseSpeed) * (maxScale - 1);
                textComponent.transform.localScale = initialScale * scale;

                // Jitter effect
                float jitterX = Random.Range(-jitterAmount, jitterAmount) * Mathf.Sin(Time.time * jitterSpeed);
                float jitterY = Random.Range(-jitterAmount, jitterAmount) * Mathf.Sin(Time.time * jitterSpeed);
                textComponent.transform.localPosition = initialPosition + new Vector3(jitterX, jitterY, 0);

                elapsedTime += Time.deltaTime;
                yield return null;
            }

            // Reset to initial state after animation
            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;
        }
    }
}