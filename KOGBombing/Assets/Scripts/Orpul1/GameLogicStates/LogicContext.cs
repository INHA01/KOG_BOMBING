using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Orpul1
{
    public class LogicContext : MonoBehaviour
    {
        public GameObject playerObj;
        public RaiseEventOptions options = new RaiseEventOptions();
        public StringBuilder selectCharacterPath = new StringBuilder();
        public GameRoundData roundData = new GameRoundData();
        public TeamUIController teamUIController = new TeamUIController();
    }
}
