using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class TextSlideIn : MonoBehaviour
    {
        public TextMeshProUGUI textComponent;
        public float startOffset = -500f;       // Offset to the left of the initial position
        public float moveSpeed = 300f;          // Speed at which the text moves to its start position

        private Vector2 initialPosition;
        private Coroutine animationCoroutine;

        private void Awake()
        {
            // Ensure textComponent is assigned and cache the initial anchored position
            if (textComponent == null)
            {
                Debug.LogError("Text Component is not assigned in the Inspector.");
                return;
            }
            initialPosition = textComponent.rectTransform.anchoredPosition;
        }

        private void OnEnable()
        {
            StartSlideIn();
        }

        private void OnDisable()
        {
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
                animationCoroutine = null;
            }
            textComponent.rectTransform.anchoredPosition = initialPosition;
        }

        public void StartSlideIn()
        {
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
            }

            // Start with text to the left of its initial position
            textComponent.rectTransform.anchoredPosition = initialPosition + Vector2.left * startOffset;

            // Ensure UI element updates visually
            Canvas.ForceUpdateCanvases();

            // Start the slide-in animation
            animationCoroutine = StartCoroutine(SlideIn());
        }

        private IEnumerator SlideIn()
        {
            // While the text position is not close to the initial position, keep moving it
            while (Vector2.Distance(textComponent.rectTransform.anchoredPosition, initialPosition) > 0.1f)
            {
                textComponent.rectTransform.anchoredPosition = Vector2.MoveTowards(textComponent.rectTransform.anchoredPosition, initialPosition, moveSpeed * Time.deltaTime);
                yield return null;
            }

            // Snap the text position exactly to the initial position at the end
            textComponent.rectTransform.anchoredPosition = initialPosition;
        }
    }
}