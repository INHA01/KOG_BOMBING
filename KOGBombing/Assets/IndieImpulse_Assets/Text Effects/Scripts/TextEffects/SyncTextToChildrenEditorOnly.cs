using UnityEditor;
using UnityEngine;
using TMPro;

namespace IndieImpulseAssets
{

    [ExecuteInEditMode]
    [RequireComponent(typeof(TextMeshProUGUI))]
    public class SyncTextToChildrenEditorOnly : MonoBehaviour
    {
        private TextMeshProUGUI parentText;
        private string previousText;

        private void OnEnable()
        {
            parentText = GetComponent<TextMeshProUGUI>();
            if (parentText != null)
            {
                previousText = parentText.text;
            }
            UpdateChildTexts();
        }

        private void Update()
        {
            if (parentText == null) return;

            // Check if the text has changed
            if (parentText.text != previousText)
            {
                previousText = parentText.text;
                UpdateChildTexts();
            }
        }

        public void UpdateChildTexts()
        {
            foreach (Transform child in transform)
            {
                TextMeshProUGUI childText = child.GetComponent<TextMeshProUGUI>();
                if (childText != null)
                {
                    childText.text = parentText.text;
                }
            }
        }
    }

    // Custom Editor for Sync Button
#if UNITY_EDITOR
    [CustomEditor(typeof(SyncTextToChildrenEditorOnly))]
    public class SyncTextToChildrenEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            if (GUILayout.Button("Sync Text to Children"))
            {
                ((SyncTextToChildrenEditorOnly)target).UpdateChildTexts();
            }
        }
    }
#endif
}