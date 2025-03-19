using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public class PhotonDataManager 
{
    Dictionary<string, PlayerBlackBoard> dictPlayerBlackBoard = new Dictionary<string, PlayerBlackBoard>();
    List<PlayerBlackBoard> myTeamBlackBoards = new List<PlayerBlackBoard>();

    public int blackBoardCnt { get { return dictPlayerBlackBoard.Count; } }

    public void AddPlayerBlackBoard(string nickname, PlayerBlackBoard blackBoard)
    {
        Debug.Log($"add ID {blackBoard.nickname}");
        dictPlayerBlackBoard.Add(nickname, blackBoard);
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        if (myTeam != blackBoard.playerTeam) return;
        myTeamBlackBoards.Add(blackBoard);
    }
    public bool IsContainKey(string key)
    {
        return dictPlayerBlackBoard.ContainsKey(key);
    }
    public PlayerBlackBoard GetPlayerBlackBoard(string nickname)
    {
        if(!dictPlayerBlackBoard.ContainsKey(nickname))
        {
            Debug.Log("NULL blackBoard!");
            return null;
        }
        return dictPlayerBlackBoard[nickname];
    }
    public PlayerBlackBoard GetMyTeamBlackboard(int index)
    {
        if (index < 0 || myTeamBlackBoards.Count <= index) return null;
        return myTeamBlackBoards[index];
    }
    public void Init()
    {
        dictPlayerBlackBoard.Clear();
        myTeamBlackBoards.Clear();
    }

}
