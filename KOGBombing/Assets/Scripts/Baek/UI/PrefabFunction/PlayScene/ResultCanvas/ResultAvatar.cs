using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResultAvatar : MonoBehaviour
{
    [SerializeField] GameObject[] avatarParents = new GameObject[4];
    void Start()
    {
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
        int teamCount = 0;
        if(team == ETeam.REDTEAM)
            teamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
        else
            teamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
        for(int i = 0; i < teamCount; i++)
        {
            GameObject avatar = Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultPlayer");
            avatar.transform.SetParent(avatarParents[i].transform);
            avatar.transform.localPosition = Vector3.zero;
        }
    }
}
