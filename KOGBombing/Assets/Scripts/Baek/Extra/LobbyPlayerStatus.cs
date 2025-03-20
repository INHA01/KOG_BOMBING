using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;
using BAEK;

[CreateAssetMenu(fileName = "LobbyPlayerStatus", menuName = "LobbyPlayerStatus")]
public class LobbyPlayerStatus : ScriptableObject
{
    [TextArea(3, 10)]
    public string[] description = new string[(int)VideoType.Max];
    public string[] skillName = new string[(int)VideoType.Max];
    public Sprite[] skillIcon = new Sprite[(int)VideoType.Max];
    public Sprite[] sprites = new Sprite[(int)SpriteType.Max];
    public VideoClip[] skillVideoClip = new VideoClip[(int)VideoType.Max];
}
