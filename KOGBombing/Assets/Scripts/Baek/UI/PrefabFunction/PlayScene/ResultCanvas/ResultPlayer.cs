using Michsky.UI.Shift;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public enum ResultText
{
    Nickname,
    Kill,
    Death,
    Assist,
    Max
}
// 포톤 적용시 삭제
public enum ResultPlayerType
{
    Ned,
    Uni,
    Max
}
public enum ResultTeam
{
    Win,
    Lose,
    NONE,
    Max
}
public class ResultPlayer : MonoBehaviour
{
    [SerializeField] GameObject[] players = new GameObject[2];
    public TextMeshProUGUI[] texts = new TextMeshProUGUI[4];
    [SerializeField] GameObject[] resultTeam = new GameObject[2];
    public ResultPlayerType playerType;
    public ResultTeam team;
    void Awake()
    {
        
        /*for(int i = 0; i < (int)ResultText.Max; i++)
        {
            if(i == (int)playerType)
                players[i].SetActive(true);
            if(i == (int)team)
                resultTeam[i].SetActive(true);
        }*/
    }
    public void SetResultPlayer()
    {
        players[(int)playerType].SetActive(true);
        if (team == ResultTeam.NONE) return;
        resultTeam[(int)team].SetActive(true);

    }
}
