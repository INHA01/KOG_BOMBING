using UnityEngine;
using TMPro;
using System.Collections;
using UnityEngine.EventSystems;

namespace IndieImpulseAssets
{
    public class GlitchTextEffect : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
    {
        public TMP_Text textMeshPro;  // Reference to the TextMeshPro component
        public float glitchDuration = 0.5f;  // Total glitch time
        public float glitchInterval = 0.05f;  // Time between each glitch
        public bool Onclick=false;
        private string originalText;  // Original text to restore after glitch
        private bool isGlitching = false;  // Track if glitch effect is ongoing


        private void Awake()
        {
            if (textMeshPro == null)
            {
                textMeshPro = GetComponent<TMP_Text>();
            }
            originalText = textMeshPro.text;
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            if(!Onclick)
            StartGlitchEffect();
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            if (!Onclick)
                StopGlitchEffect();
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (Onclick)
                StartGlitchEffect();
        }

        // Public method to start the glitch effect
        public void StartGlitchEffect()
        {
            if (!isGlitching)
            {
                StartCoroutine(GlitchEffect());
            }
        }

        // Public method to stop the glitch effect
        public void StopGlitchEffect()
        {
            StopAllCoroutines();
            isGlitching = false;
            textMeshPro.text = originalText;
        }

        private IEnumerator GlitchEffect()
        {
            isGlitching = true;
            float timeElapsed = 0f;

            while (timeElapsed < glitchDuration)
            {
                // Generate a glitched version of the original text
                string glitchedText = GenerateGlitchedText(originalText);
                textMeshPro.text = glitchedText;

                yield return new WaitForSeconds(glitchInterval);
                timeElapsed += glitchInterval;
            }

            // After glitching, restore the original text
            textMeshPro.text = originalText;
            isGlitching = false;
        }

        private string GenerateGlitchedText(string text)
        {
            char[] characters = text.ToCharArray();

            for (int i = 0; i < characters.Length; i++)
            {
                // Randomly swap a character with a random one for the glitch effect
                if (Random.Range(0f, 1f) > 0.5f)
                {
                    characters[i] = (char)Random.Range(33, 126); // ASCII characters from '!' to '~'
                }
            }

            return new string(characters);
        }
    }
}