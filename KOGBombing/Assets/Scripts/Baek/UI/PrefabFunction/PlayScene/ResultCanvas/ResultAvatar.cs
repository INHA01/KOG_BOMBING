using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class ResultAvatar : MonoBehaviour,ISetWinTypeable
{
    [SerializeField] GameObject[] avatarParents = new GameObject[4];
    ResultTeam bestPlayerType = ResultTeam.NONE;
    public void SetWinType(ResultTeam type)
    {
        bestPlayerType = type;
    }

    void Start()
    {
        int index = 0;
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        Player[] players = PhotonNetwork.PlayerList;
        StringBuilder bestPlayer = Managers.PointData.BestPlayer;
        
        for (int i = 0; i < players.Length; i++)
        {
            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString().ToString()] == team)
            {
                GameObject avatar = LocalManagers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultPlayer");
                avatar.transform.SetParent(avatarParents[index++].transform);
                avatar.transform.localPosition = Vector3.zero;
                
                PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
                ResultPlayer resultPlayer = avatar.GetComponent<ResultPlayer>();
                resultPlayer.playerType = (ResultPlayerType)Managers.RoundData.CharacterSelects[players[i].NickName];
                resultPlayer.texts[(int)ResultText.Nickname].text = players[i].NickName;
                resultPlayer.texts[(int)ResultText.Kill].text = pointInfo.KillPoint.ToString();
                resultPlayer.texts[(int)ResultText.Death].text = pointInfo.DeathPoint.ToString();
                resultPlayer.texts[(int)ResultText.Assist].text = pointInfo.AsistPoint.ToString();
                if(bestPlayer.ToString() == players[i].NickName)
                    resultPlayer.team = bestPlayerType;
                else
                    resultPlayer.team = ResultTeam.NONE;

                resultPlayer.SetResultPlayer();
            }
        }
    }
}
