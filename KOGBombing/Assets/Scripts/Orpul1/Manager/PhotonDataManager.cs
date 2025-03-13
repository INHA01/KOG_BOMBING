using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public class PhotonDataManager 
{
    Dictionary<string, PlayerBlackBoard> dictPlayerBlackBoard = new Dictionary<string, PlayerBlackBoard>();
    Dictionary<int, PlayerInfo> dictPlayerInfo = new Dictionary<int, PlayerInfo>();
    List<PlayerBlackBoard> blackBoardList = new List<PlayerBlackBoard>();
    public int blackBoardCnt { get { return dictPlayerBlackBoard.Count; } }

    public void AddPlayerBlackBoard(string nickname, PlayerBlackBoard blackBoard)
    {
        Debug.Log($"add ID {blackBoard.nickname}");
        dictPlayerBlackBoard.Add(nickname, blackBoard);
        blackBoardList.Add(blackBoard);
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
    public List<PlayerBlackBoard> GetAllBlackBoard()
    {
        return blackBoardList;
    }
    public void Init()
    {
        dictPlayerBlackBoard.Clear();
        blackBoardList.Clear();
    }

}
