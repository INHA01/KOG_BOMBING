using UnityEngine;
using TMPro;

namespace IndieImpulseAssets
{
    public class PingPongTextMeshProMaterial : MonoBehaviour
    {
        public TextMeshProUGUI textMeshPro; // Assign in Inspector
        private Material textMaterial;
        private Color originalFaceColor;
        public float minIntensity = 2.3f;
        public float maxIntensity = 3.3f;
        public float speed = 1.0f; // Adjust to control the speed of ping pong effect


        private void OnEnable()
        {
            // Get the material from TextMeshProUGUI component
            if (textMeshPro != null)
            {
                textMaterial = textMeshPro.fontMaterial;

                // Store the original face color
                originalFaceColor = textMaterial.GetColor("_FaceColor");
            }
        }
        void Update()
        {
            if (textMaterial != null)
            {
                // Calculate PingPong effect for intensity between minIntensity and maxIntensity
                float intensity = Mathf.PingPong(Time.time * speed, maxIntensity - minIntensity) + minIntensity;

                // Create a new color with HDR intensity
                Color hdrColor = originalFaceColor * intensity;

                // Set the HDR face color
                textMaterial.SetColor("_FaceColor", hdrColor);
            }
        }
    }
}