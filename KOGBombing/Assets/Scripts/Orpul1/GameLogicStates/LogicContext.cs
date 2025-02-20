using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class LogicContext : MonoBehaviour
{
    public GameObject playerObj;
    public RaiseEventOptions options = new RaiseEventOptions();
    public StringBuilder selectCharacterPath = new StringBuilder();
    public GameRoundData roundData = new GameRoundData();
}
