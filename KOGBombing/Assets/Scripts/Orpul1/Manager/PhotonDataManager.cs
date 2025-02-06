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
    public bool IsDataAllGet = false;

    public void AddPlayerBlackBoard(string nickname, PlayerBlackBoard blackBoard)
    {
        Debug.Log($"add ID {blackBoard.nickname}");
        dicPlayerBlackBoard.Add(nickname, blackBoard);
        blackBoardList.Add(blackBoard);
        if (PhotonNetwork.PlayerList.Length == dicPlayerBlackBoard.Count)
            IsDataAllGet = true;
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
        dicPlayerKDA.Clear();
    }

}
