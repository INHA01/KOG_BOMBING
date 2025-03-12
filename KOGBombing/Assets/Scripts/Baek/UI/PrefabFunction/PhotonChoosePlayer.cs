using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;


public class PhotonChoosePlayer : ChoosePlayer
{
    [SerializeField] SelectCharacterSound sound;
    PhotonChooseAvatar photonAvatar = new PhotonChooseAvatar();
    List<Player> mTeamPlayerList;
    Queue<int> mTeamIndex = new Queue<int>();
    int playerTeamIndex = 0;
    ETeam eTeam;
    
    RaiseEventOptions option = new RaiseEventOptions();

    protected void Awake()
    {
        option.Receivers = ReceiverGroup.All;
    }
    private void OnDisable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= OnSelectEvent;
    }
    public override void Notify(int index)
    {
        SoundManager.Instance.PlayEffect(sound.selectSound[index],EMixerGroup.CHARACTER);
        base.Notify(index);
        object[] sendMsg = new object[4] { index, playerTeamIndex,PhotonNetwork.LocalPlayer.NickName, eTeam };
        PhotonNetwork.RaiseEvent((int)PunEventType.CHOOSEPLAYER, sendMsg, option, SendOptions.SendReliable);
    }
    private void OnSelectEvent(EventData punEvent)
    {
        if(punEvent.Code == (int)PunEventType.CHOOSEPLAYER)
        {
            Debug.Log("On ChoosePlayer Event");
            object[] receiveMsg = (object[])punEvent.CustomData;
            int receiveChooseIndex = (int)receiveMsg[0];
            int receiveTeamIndex = (int)receiveMsg[1];
            string playerNickname = (string)receiveMsg[2];
            ETeam receiveTeamType = (ETeam)receiveMsg[3];
            Debug.Log($"PlayerSelct {playerNickname}, {(CharacterType)receiveChooseIndex}");
            Managers.RoundData.SetSelectCharacter(playerNickname, (CharacterType)receiveChooseIndex);
            if (receiveTeamType != eTeam) return;
            ChooseAvatarIcon chooseAvatarIcon = photonAvatar.GetPlayerAvatar(receiveTeamIndex);
            if (chooseAvatarIcon == null) return;
            chooseAvatarIcon.Choosing(receiveChooseIndex);
        }
    }
    public override void Init()
    {
        InitAvatar();
        eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        playerTeamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];

        PhotonNetwork.NetworkingClient.EventReceived += OnSelectEvent;
        mTeamPlayerList = GetTeamPlayer(eTeam);
        
        //플레이어 아이콘 생성
        for (int i = 0; i < mTeamPlayerList.Count; i++) 
        {
            if (mTeamPlayerList[i] == PhotonNetwork.LocalPlayer)
                SetIcon(true);
            else
                SetIcon(false);
        }
        base.Init();
    }
    private void InitAvatar()
    {
        if (photonAvatar.IsNull()) return;
        List<ChooseAvatarIcon> avatarList = photonAvatar.GetPlayerAvatarList();
        for (int i = 0; i < avatarList.Count; i++)
        {
            Destroy(avatarList[i].gameObject);
        }
        photonAvatar.RemoveAll();
    }
    private List<Player> GetTeamPlayer(ETeam eTeam)
    {
        List<Player> teamPlayerList = new List<Player>();
        Player[] players = PhotonNetwork.PlayerList;
        for(int i=0; i<players.Length; i++)
        {
            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] == eTeam)
            {
                teamPlayerList.Add(players[i]);
                mTeamIndex.Enqueue((int)players[i].CustomProperties[EPropertyType.TEAMINDEX.ToString()]);
            }
        }
        return teamPlayerList;
    }
    public override void SetIcon(bool isMine)
    {
        GameObject go = null;
        go = LocalManagers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/ChoosePlayer/IconBack");
        go.transform.SetParent(teamIconBack);
        int teamIndex = mTeamIndex.Dequeue();
        if (isMine)
        {
            go.GetComponent<ChooseAvatarIcon>().SetSubject(this, true);
        }
        else
        { 
            photonAvatar.AddPlayerAvatar(teamIndex, go.GetComponent<ChooseAvatarIcon>());
        }
    }

}
