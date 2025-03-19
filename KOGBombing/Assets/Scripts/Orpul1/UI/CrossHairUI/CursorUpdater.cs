using System.Collections;
using System.Collections.Generic;
using Unity.Burst.Intrinsics;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
public enum EScene
{
    LobbyScene,
    MainGame,
    END
}
public class CursorUpdater : MonoBehaviour
{
    [SerializeField] GameObject cursorUI;
    [SerializeField] List<Sprite> cursorList = new List<Sprite>();
    [SerializeField] Camera crossHairCamera;
    Dictionary<string, Sprite> dictCusrsor = new Dictionary<string, Sprite>();
    EScene curCursor = EScene.LobbyScene;
    void Start()
    {
        SceneManager.sceneLoaded += UpdateCursor;
        for (int i = 0; i < (int)EScene.END; i++)
        {
            EScene type = (EScene)i;
            dictCusrsor.Add(type.ToString(), cursorList[i]);
        }
        Cursor.visible = false;
    }
    void Update()
    {
        cursorUI.transform.position = Input.mousePosition;
    }
    private void UpdateCursor(Scene arg, LoadSceneMode mode)
    {
        Cursor.visible = false;
        if (!dictCusrsor.ContainsKey(arg.name)) return;
        Sprite cursorTexture = dictCusrsor[arg.name];
        cursorUI.GetComponent<Image>().sprite = cursorTexture;
    }
}
