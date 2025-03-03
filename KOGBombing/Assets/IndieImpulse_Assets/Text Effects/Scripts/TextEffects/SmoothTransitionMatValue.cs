using System.Collections;
using TMPro;
using UnityEngine;

namespace IndieImpulseAssets
{
    public class SmoothTransitionMatValue : MonoBehaviour
    {
        public TextMeshProUGUI textMeshPro; // Assign in Inspector
        public Material textMaterial;
        public MainMenuManager mainMenuManager;
        public string MatValue = "_Step";
        public float startStep = 0.8f;
        public float endStep = 1f;
        public float duration = 1f;

        private Coroutine transitionCoroutine;

       

        private void OnEnable()
        {
            // Get the material from TextMeshProUGUI component
            if (textMeshPro != null)
            {
                textMaterial = mainMenuManager.hoverFont.material;
            }
            StartStepTransition(); // Start the transition when enabled
        }

        private void OnDisable()
        {
            // Stop the coroutine to reset if disabled
            if (transitionCoroutine != null)
            {
                StopCoroutine(transitionCoroutine);
                transitionCoroutine = null;
            }
        }

        public void StartStepTransition()
        {
            // Stop any previous coroutine before starting a new one
            if (transitionCoroutine != null)
            {
                StopCoroutine(transitionCoroutine);
            }
            transitionCoroutine = StartCoroutine(SmoothStepTransition(startStep, endStep, duration));
        }

        private IEnumerator SmoothStepTransition(float startValue, float endValue, float duration)
        {
            if (textMaterial != null)
            {
                float elapsedTime = 0f;

                while (elapsedTime < duration)
                {
                    elapsedTime += Time.deltaTime;
                    float stepValue = Mathf.Lerp(startValue, endValue, elapsedTime / duration);
                    textMaterial.SetFloat(MatValue, stepValue);
                    yield return null;
                }

                // Ensure the final value is set
                textMaterial.SetFloat(MatValue, endValue);
            }
        }
    }
}