using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using Semin;
using UnityEngine;

[Serializable]
public class PlayerStateData: IComparer<PlayerStateData>
{
    public GameObject playerObj;
    public Rigidbody rigidBody;
    public PlayerStatus playerStatus;
    public StringBuilder nickname = new StringBuilder();
    public Vector3 spawnPosi = Vector3.zero;
    public ETeam playerTeam = ETeam.REDTEAM;
    public int playerIndex = 0;

    public int Compare(PlayerStateData data1, PlayerStateData data2)
    {
        return data1.playerIndex > data2.playerIndex ? 1 : -1;
    }
}
public class PhotonDataManager 
{
    List<PlayerStateData> playerStateDataList = new List<PlayerStateData>();
    List<PlayerBlackBoard> blackBoardList = new List<PlayerBlackBoard>();
    public int DataCount { get { return playerStateDataList.Count; } }

    public void AddPlayerBlackBoard(PlayerStateData playerStateData)
    {
        Debug.Log($"add ID {playerStateData.nickname}");
        playerStateDataList.Add(playerStateData);
        playerStateDataList.Sort(playerStateData);
    }
    public bool IsContainKey(int index)
    {
        if (index < 0) return false;
        if (index >= playerStateDataList.Count) return false;
        return true;
    }
    public PlayerStateData GetPlayerStateData(int index )
    {
        if(!IsContainKey(index))
        {
            Debug.Log($"NULL PlayerStateData! index is {index}");
            return null;
        }
        return playerStateDataList[index];
    }
    public List<PlayerStateData> GetAllStateData()
    {
        return playerStateDataList;
    }
    
    public void Init()
    {
        playerStateDataList.Clear();
        blackBoardList.Clear();
    }

}
