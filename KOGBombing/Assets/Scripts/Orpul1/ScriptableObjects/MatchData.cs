using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

public enum ELobbyType
{
    CUSTOMMATCH,
    RANDOMMATCH,
    DEVELOPMEENTMATCH,
}

[CreateAssetMenu(fileName = "MatchData",menuName = "Datas/MatchData")]
public class MatchData : ScriptableObject
{
    public ELobbyType LobbyName;
    public LobbyType LobbyType;
    public float StartDelay;
    public float UpdateDelay;
    public int MaxPlayer;
}
