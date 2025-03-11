using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

[CreateAssetMenu(fileName = "MatchData",menuName = "Datas/MatchData")]
public class MatchData : ScriptableObject
{
    public string LobbyName;
    public LobbyType LobbyType;
    public float StartDelay;
    public float UpdateDelay;
    public int MaxPlayer;
}
