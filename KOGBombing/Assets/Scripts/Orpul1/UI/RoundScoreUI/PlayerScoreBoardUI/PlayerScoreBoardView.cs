using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayerScoreBoardView : MonoBehaviour
{
    public TextMeshProUGUI tmpNickname;
    public TextMeshProUGUI tmpKillScore;
    public TextMeshProUGUI tmpAsistScore;
    public TextMeshProUGUI tmpDeathScore;
    private TextMeshProUGUI[] textUIarray { get { return new TextMeshProUGUI[] { tmpNickname, tmpKillScore, tmpAsistScore, tmpDeathScore }; } }
    private Dictionary<EPlayerScore, TextMeshProUGUI> dicTextUI = new Dictionary<EPlayerScore, TextMeshProUGUI> ();
    public Dictionary<EPlayerScore, TextMeshProUGUI> Texts { get { return dicTextUI; } }
    private void Start()
    {
        TextMeshProUGUI[] textUIs = textUIarray;
        for (int i = 0; i < (int)EPlayerScore.END; i++) 
        {
            dicTextUI.Add((EPlayerScore)i, textUIs[i]);
        }
    }
}
