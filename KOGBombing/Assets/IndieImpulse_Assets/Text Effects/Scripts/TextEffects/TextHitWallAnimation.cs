using UnityEngine;
using TMPro;
using System.Collections;

namespace IndieImpulseAssets
{
    public class TextHitWallAnimation : MonoBehaviour
    {
        public TextMeshProUGUI textComponent;
        public float moveDistance = 200f;      // Maximum distance the text moves away from the starting point
        public float moveSpeed = 200f;         // Speed at which the text moves away and returns
        public float impactScale = 1.2f;       // Scale applied on impact with the wall
        public float bounceDuration = 0.5f;    // Duration of the bounce back effect

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
            StartAnimateText();
        }

        private void OnDisable()
        {
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
                animationCoroutine = null;
            }
            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;
        }

        public void StartAnimateText()
        {
            if (animationCoroutine != null)
            {
                StopCoroutine(animationCoroutine);
            }

            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;

            animationCoroutine = StartCoroutine(AnimateText());
        }

        private IEnumerator AnimateText()
        {
            // Step 1: Move text away from the wall (starting position)
            float targetPositionX = initialPosition.x + moveDistance;
            while (textComponent.transform.localPosition.x < targetPositionX)
            {
                textComponent.transform.localPosition += Vector3.right * moveSpeed * Time.deltaTime;
                yield return null;
            }

            // Step 2: Move back towards the wall
            while (textComponent.transform.localPosition.x > initialPosition.x)
            {
                textComponent.transform.localPosition -= Vector3.right * moveSpeed * Time.deltaTime;
                yield return null;
            }

            // Step 3: Simulate impact with a quick scale-up effect when reaching the wall
            textComponent.transform.localScale = initialScale * impactScale;
            yield return new WaitForSeconds(0.1f);  // Hold the scale briefly to show impact

            // Step 4: Reset scale and position after impact
            textComponent.transform.localScale = initialScale;
            textComponent.transform.localPosition = initialPosition;
        }
    }
}