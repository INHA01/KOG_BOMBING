using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public enum EPlayerLogType
{
    KILLEDPLAYER,
    DIEDPLAYER,
    END,
}
public class KillLogUIView : MonoBehaviour
{
    public TextMeshProUGUI[] tmpPlayerNicknames;
    public Image[] panelImages;
    public GameObject killLogPanel;
}
