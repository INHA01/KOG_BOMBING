using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class TextMenuItem : MonoBehaviour
{
    protected TextMeshProUGUI tmpText;
    public void SetMaterial(TMP_FontAsset font)
    {
        tmpText.font = null;
        tmpText.font = font;
        // Set the material for the TextMeshProUGUI component

        // Ensure the TMP text is updated and the mesh is refreshed
        tmpText.ForceMeshUpdate();

    }
}
