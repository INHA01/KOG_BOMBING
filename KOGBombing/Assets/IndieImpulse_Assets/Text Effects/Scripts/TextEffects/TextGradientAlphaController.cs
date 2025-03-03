using UnityEngine;
using TMPro;

namespace IndieImpulseAssets
{
    public class TextGradientAlphaController : MonoBehaviour
    {
        public TextMeshProUGUI textMeshPro;
        public float duration = 2f; // Total duration for the entire text fade-in effect
        [Range(0, 1)] public float fadeOverlap = 0.7f; // Control for fade overlap; 0 = no overlap, 1 = full overlap

        private float elapsedTime = 0f;

        void OnEnable()
        {
            elapsedTime = 0f;
        }

        void Update()
        {
            if (textMeshPro == null) return;

            // Increase the elapsed time
            elapsedTime += Time.deltaTime;

            // Update the text mesh to access vertex data
            textMeshPro.ForceMeshUpdate();

            var textInfo = textMeshPro.textInfo;
            int characterCount = textInfo.characterCount;
            int visibleCharacterIndex = 0; // To track visible characters only

            // Iterate through each character from left to right
            for (int i = 0; i < characterCount; i++)
            {
                if (!textInfo.characterInfo[i].isVisible || textInfo.characterInfo[i].character == ' ')
                    continue; // Skip spaces and invisible characters

                int vertexIndex = textInfo.characterInfo[i].vertexIndex;
                Color32[] vertexColors = textInfo.meshInfo[textInfo.characterInfo[i].materialReferenceIndex].colors32;

                // Calculate delay based on visible character index
                float startDelay = visibleCharacterIndex * ((duration * (1 - fadeOverlap)) / characterCount);
                float characterElapsed = elapsedTime - startDelay;

                // Calculate progress with smooth transition
                float characterProgress = Mathf.Clamp01(characterElapsed / duration);
                float smoothAlpha = Mathf.SmoothStep(0f, 1f, characterProgress);

                // Apply calculated alpha to each vertex of the character
                byte alpha = (byte)(smoothAlpha * 255);
                for (int j = 0; j < 4; j++)
                {
                    vertexColors[vertexIndex + j].a = alpha;
                }

                visibleCharacterIndex++; // Increment for visible characters only
            }

            // Update vertex colors in the TextMeshPro component
            textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        }
    }
}