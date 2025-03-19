using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum ECursorType
{
    MENU_CURSOR,
    GAME_CURSOR
}
public class CursorManager : MonoBehaviour
{
    [SerializeField] List<Texture> mCursors = new List<Texture>();
    ECursorType curCursor = ECursorType.MENU_CURSOR;
    void Start()
    {
    }

    void Update()
    {
        
    }
}
