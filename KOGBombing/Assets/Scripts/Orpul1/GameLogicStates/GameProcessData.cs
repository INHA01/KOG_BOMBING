using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using BAEK;

namespace Orpul1
{
    public class GameProcessData : MonoBehaviour
    {
        public GameObject playerObj;
        public RaiseEventOptions options = new RaiseEventOptions();
        public StringBuilder selectCharacterPath = new StringBuilder();
        public TeamUIController teamUIController = new TeamUIController();
        public Transform[] bombPos = new Transform[(int)BombCursorType.Max];
        public ISetGameStateAble playerSetGameState;
        public IUpdateScore battleBoard;

        private void Start()
        {
            teamUIController.Init(bombPos);
            options.Receivers = ReceiverGroup.All;
            battleBoard = Managers.UI.GetPopupUI<BattleBoardUpdater>(UIKEY.BattleBoard);
        }
    }
}
