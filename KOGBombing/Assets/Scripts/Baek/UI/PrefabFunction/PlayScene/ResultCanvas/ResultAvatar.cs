using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResultAvatar : MonoBehaviour
{
    [SerializeField] GameObject[] avatarParents = new GameObject[4];
    void Start()
    {
        int index = 0;
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM];
        Player[] players = PhotonNetwork.PlayerList;
        for(int i = 0; i < players.Length; i++)
        {
            if ((ETeam)players[i].CustomProperties[(int)EPropertyType.TEAM] == team)
            {
                GameObject avatar = Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultPlayer");
                avatar.transform.SetParent(avatarParents[index++].transform);
                avatar.transform.localPosition = Vector3.zero;

                PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
                avatar.GetComponent<ResultPlayer>().texts[(int)ResultText.Nickname].text = players[i].NickName;
                avatar.GetComponent<ResultPlayer>().texts[(int)ResultText.Kill].text = pointInfo.KillPoint.ToString();
                avatar.GetComponent<ResultPlayer>().texts[(int)ResultText.Death].text = pointInfo.DeathPoint.ToString();
                avatar.GetComponent<ResultPlayer>().texts[(int)ResultText.Assist].text = pointInfo.AsistPoint.ToString();
            }
        }
    }
}
