using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Orpul1;
using Photon.Realtime;
using UnityEngine;

public class KillLogUIModel : MonoBehaviour
{
    public StringBuilder[] playerNicknames = new StringBuilder[2];
    public ETeam[] playerTeam = new ETeam[2];
    public Color[] backgroundColors;
    public float deactiveTime = 0;
    Action updateUI;
    public void Initialize(Action updateUI)
    {
        this.updateUI = updateUI;
        for(int i = 0; i<2; i++)
        {
            playerNicknames[i] = new StringBuilder();
        }
    }
    public void SetPlayerInfo(PlayerInfo[] logInfos)
    {
        for (int i = 0; i < (int)EPlayerLogType.END; i++)
        {
            playerNicknames[i].Clear();
            playerNicknames[i].Append(logInfos[i].nickname);
            playerTeam[i] = logInfos[i].team;
        }
        updateUI();
    }
}
