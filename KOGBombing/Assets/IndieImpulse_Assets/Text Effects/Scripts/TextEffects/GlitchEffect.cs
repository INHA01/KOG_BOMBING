using UnityEngine;

namespace IndieImpulseAssets
{
    public class GlitchEffect : MonoBehaviour
    {
        public RectTransform rectTransform;
        public float glitchSpeed = 10f;  // Speed of the glitch effect
        public float minX = 174f;        // Minimum X position
        public float maxX = 180f;        // Maximum X position

        private float glitchTime;

        void Update()
        {
            // Increase glitchTime based on time and speed
            glitchTime += Time.deltaTime * glitchSpeed;

            // Create a jittery effect using Mathf.PerlinNoise or Mathf.Sin for randomness
            float randomGlitch = Mathf.Sin(glitchTime * Random.Range(0.8f, 1.2f)) * 0.5f + 0.5f;

            // Map the random value between minX and maxX
            float posX = Mathf.Lerp(minX, maxX, randomGlitch);

            // Set the X position of the RectTransform
            rectTransform.anchoredPosition = new Vector2(posX, rectTransform.anchoredPosition.y);
        }
    }
}