using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CursorManager : MonoBehaviour
{
    [SerializeField] List<Texture2D> cursorList = new List<Texture2D>();
    Dictionary<string, Texture2D> dictCusrsor = new Dictionary<string, Texture2D>();
    EScene curCursor = EScene.LobbyScene;
    void Start()
    {
        SceneManager.sceneLoaded += UpdateCursor;
        for(int i=0; i<(int)EScene.END; i++)
        {
            EScene type = (EScene)i;
            dictCusrsor.Add(type.ToString(), cursorList[i]);
        }
    }
    private void UpdateCursor(Scene arg, LoadSceneMode mode)
    {
        if (!dictCusrsor.ContainsKey(arg.name)) return;
        Texture2D cursorTexture = dictCusrsor[arg.name];
        Vector2 cursorSize = cursorTexture.texelSize * 0.5f;
        Cursor.SetCursor(cursorTexture, cursorSize, CursorMode.Auto);
    }
    private void UpdateHitCursor()
    {

    }
}
