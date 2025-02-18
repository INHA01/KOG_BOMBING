using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;


public class PhotonChoosePlayer : MonoBehaviour
{
    [SerializeField]
    Transform teamIconBack;
    PhotonChooseAvatar photonAvatar = new PhotonChooseAvatar();
    List<Player> mTeamPlayerList;
    Queue<int> mTeamIndex = new Queue<int>();
    int playerTeamIndex = 0;

    RaiseEventOptions option = new RaiseEventOptions();
    int eventCode = 12;

    void Awake()
    {
        if (PhotonNetwork.OfflineMode == true) return;
        PhotonNetwork.NetworkingClient.EventReceived += OnSelectEvent;
        option.Receivers = ReceiverGroup.All;
        Init();
    }
    public void ChangeOtherPlayerIcon(int index)
    {
        object[] sendMsg = new object[2] { index, playerTeamIndex };
        PhotonNetwork.RaiseEvent((byte)eventCode, sendMsg, option, SendOptions.SendReliable);
    }
    private void OnSelectEvent(EventData punEvent)
    {
        if(punEvent.Code == (byte)eventCode)
        {
            object[] receiveMsg = (object[])punEvent.CustomData;
            int receiveChooseIndex = (int)receiveMsg[0];
            int receiveTeamIndex = (int)receiveMsg[1];
            ChooseAvatarIcon chooseAvatarIcon = photonAvatar.GetPlayerAvatar(receiveTeamIndex);
            if (chooseAvatarIcon == null) return;
            chooseAvatarIcon.Choosing(receiveChooseIndex);
        }
    }
    void Init()
    {
        ETeam eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
        playerTeamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
        mTeamPlayerList = GetTeamPlayer(eTeam);
        int playerCnt = mTeamPlayerList.Count;
        
        //자기 자신을 제외한 플레이어 아이콘 생성
        for (int i = 0; i < mTeamPlayerList.Count; i++) 
        {
            CreateOtherIcon();
        }
    }
    private List<Player> GetTeamPlayer(ETeam eTeam)
    {
        List<Player> teamPlayerList = new List<Player>();
        Player[] otherPlayer = PhotonNetwork.PlayerListOthers;
        for(int i=0; i<otherPlayer.Length; i++)
        {
            if ((ETeam)otherPlayer[i].CustomProperties["Team"] == eTeam)
            {
                teamPlayerList.Add(otherPlayer[i]);
                mTeamIndex.Enqueue((int)otherPlayer[i].CustomProperties["TeamIndex"]);
            }
        }
        return teamPlayerList;
    }
    void CreateOtherIcon()
    {
        GameObject go = null;
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/ChoosePlayer/IconBack");
        go.transform.SetParent(teamIconBack);
        int teamIndex = mTeamIndex.Dequeue();
        photonAvatar.AddPlayerAvatar(teamIndex, go.GetComponent<ChooseAvatarIcon>());
    }

}
