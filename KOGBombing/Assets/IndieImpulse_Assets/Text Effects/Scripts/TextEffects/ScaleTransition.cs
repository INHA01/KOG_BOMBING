using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace IndieImpulseAssets
{
    public class ScaleTransition : MonoBehaviour
    {
        public Vector3 startScale = Vector3.one; // Starting scale
        public Vector3 targetScale = Vector3.one * 1.5f; // Target scale
        public float duration = 1f; // Duration of the transition
        public bool resetOnDisable = false; // Option to reset scale when disabled

        private RectTransform rectTransform; // Reference to RectTransform component
        private float elapsedTime = 0f;

        private void OnEnable()
        {
            rectTransform = GetComponent<RectTransform>();
            if (rectTransform == null)
            {
                Debug.LogWarning("RectTransform component is missing.");
                enabled = false;
                return;
            }

            rectTransform.localScale = startScale;
            elapsedTime = 0f;
        }

        private void Update()
        {
            if (rectTransform == null) return;

            elapsedTime += Time.deltaTime;
            float t = Mathf.Clamp01(elapsedTime / duration);
            rectTransform.localScale = Vector3.Lerp(startScale, targetScale, t);

            if (t >= 1f && resetOnDisable)
            {
                enabled = false;
            }
        }

        private void OnDisable()
        {
            if (resetOnDisable && rectTransform != null)
            {
                rectTransform.localScale = startScale;
            }
        }

        public void SetScaleDirection(float scaleX)
        {
            if (rectTransform != null)
            {
                rectTransform.localScale = new Vector3(scaleX, rectTransform.localScale.y, rectTransform.localScale.z);
            }
        }
    }
}