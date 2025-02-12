using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public struct PlayerKDA
{
    int kill;
    int death;
    int asist;
}
public class PhotonDataManager 
{
    Dictionary<string, PlayerBlackBoard> dicPlayerBlackBoard = new Dictionary<string, PlayerBlackBoard>();
    Dictionary<string, PlayerKDA> dicPlayerKDA = new Dictionary<string, PlayerKDA>();
    List<PlayerBlackBoard> blackBoardList = new List<PlayerBlackBoard>();
    public int blackBoardCnt { get { return dicPlayerBlackBoard.Count; } }

    public void AddPlayerBlackBoard(string nickname, PlayerBlackBoard blackBoard)
    {
        Debug.Log($"add ID {blackBoard.nickname}");
        dicPlayerBlackBoard.Add(nickname, blackBoard);
        blackBoardList.Add(blackBoard);
    }
    public PlayerBlackBoard GetPlayerBlackBoard(string nickname)
    {
        if(!dicPlayerBlackBoard.ContainsKey(nickname))
        {
            Debug.Log("NULL blackBoard!");
            return null;
        }
        return dicPlayerBlackBoard[nickname];
    }
    public List<PlayerBlackBoard> GetAllBlackBoard()
    {
        return blackBoardList;
    }
    public void Init()
    {
        dicPlayerBlackBoard.Clear();
        blackBoardList.Clear();
        dicPlayerKDA.Clear();
    }

}
