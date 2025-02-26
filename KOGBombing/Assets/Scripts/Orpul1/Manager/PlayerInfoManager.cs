using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInfoManager : MonoBehaviour
{
    private Dictionary<string, PlayerInfo> dicPlayers = new Dictionary<string, PlayerInfo>();
    public void AddPlayerInfo(string key, PlayerInfo info)
    {
        if (dicPlayers.ContainsKey(key)) return;
        dicPlayers.Add(key, info);
    }
    public void RemovePlayerInfo(string key)
    {
        if (!dicPlayers.ContainsKey(key)) return;
        dicPlayers.Remove(key);
    }
    public PlayerInfo GetPlayerInfo(string key)
    {
        return dicPlayers[key];
    }
}
