using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Orpul1
{
    public class GameProcessData : MonoBehaviour
    {
        public GameObject playerObj;
        public RaiseEventOptions options = new RaiseEventOptions();
        public StringBuilder selectCharacterPath = new StringBuilder();
        public TeamUIController teamUIController = new TeamUIController();
        public GameRoundData debugRoundData;
        public Transform bombPos;
        private void Start()
        {
            teamUIController.Init(bombPos.position);
            options.Receivers = ReceiverGroup.All;
        }
    }
}
