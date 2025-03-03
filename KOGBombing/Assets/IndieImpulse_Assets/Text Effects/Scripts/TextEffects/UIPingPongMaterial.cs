using UnityEngine;
using TMPro;
using UnityEngine.UI;

namespace IndieImpulseAssets
{
    public class UIPingPongMaterial : MonoBehaviour
    {
        public Image image; // Assign in Inspector
        private Material _material;
        private Color originalFaceColor;
        public float minIntensity = 2.3f;
        public float maxIntensity = 3.3f;
        public float speed = 1.0f; // Adjust to control the speed of ping pong effect


        private void OnEnable()
        {
            // Get the material from TextMeshProUGUI component
            if (image != null)
            {
                _material = image.material;

                // Store the original face color
                originalFaceColor = _material.GetColor("_OutlineColor");
            }
        }
        void Update()
        {
            if (_material != null)
            {
                // Calculate PingPong effect for intensity between minIntensity and maxIntensity
                float intensity = Mathf.PingPong(Time.time * speed, maxIntensity - minIntensity) + minIntensity;

                // Create a new color with HDR intensity
                Color hdrColor = originalFaceColor * intensity;

                // Set the HDR face color
                _material.SetColor("_OutlineColor", hdrColor);
            }
        }
    }
}