using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using BAEK;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class RoundEndWaiter : GameProcessLogic, ISetDataAble<EGameState>
    {
        [SerializeField] float roundEndTime;
        float time = 0;
        EGameState nextGameState = EGameState.ROUNDWAIT;
        public override void EnterState()
        {
            gameData.playerSetGameState.SetGameState(EGameState.ROUNDENDWAIT);
            time = 0;
            Interacting bombNotify = Managers.UI.GetPopupUI<Interacting>("InteractingCanvas");
            if(bombNotify!=null)
                bombNotify.ActiveFalseAll();
            Managers.UI.ShowPopupUI<Winner>("WinnerCanvas").SetWiner(0);
        }
        
        public override void UpdateState()
        {
            if(!IsEndWaitRoundEnd()) return;
            transitionState((int)nextGameState);
        }

        public override void ExitState()
        {
            Managers.UI.ClosePopupUI("WinnerCanvas");
            gameData.playerObj.GetComponent<IResetAble>().DoReset();
        }

        private bool IsEndWaitRoundEnd()
        {
            time+= Time.deltaTime;
            if (time > roundEndTime) 
            {
                time = 0;
                return true;
            }
            return false;
        }

        public void SetData(EGameState state)
        {
            nextGameState = state;
        }
    }

}
