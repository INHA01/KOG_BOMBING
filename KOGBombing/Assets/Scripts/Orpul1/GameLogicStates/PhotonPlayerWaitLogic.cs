using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public abstract class PhotonPlayerWaitLogic : MonoBehaviourPunCallbacks, IState
    {
        [SerializeField]
        protected GameProcessData gameData;
        protected int readyPlayerCnt = 0;
        protected Action<int> transitionState;
        protected Dictionary<string, bool> dicReadyPlayer = new Dictionary<string, bool>();
        public void Initialize(Action<int> transition, GameProcessData logicContext)
        {
            transitionState = transition;
            this.gameData = logicContext;
            this.gameData.options.Receivers = ReceiverGroup.All;
            dicReadyPlayer.Clear();
            Player[] players = PhotonNetwork.PlayerList;
            for (int i = 0; i < players.Length; i++)
            {
                dicReadyPlayer.Add(players[i].NickName, false);
            }
        }
        public virtual void EnterState()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                InitPlayerReadyState();
                SetCurReadyPlayer();
                StartCoroutine(CoWaitPlayer());
            }
        }
        public abstract void UpdateState();
        public abstract void ExitState();

        protected void InitPlayerReadyState()
        {
            for(int i=0; i<dicReadyPlayer.Count; i++)
            {
                string key = dicReadyPlayer.ElementAt(i).Key;
                dicReadyPlayer[key] = false;
            }
        }
        protected abstract void SetCurReadyPlayer();
        protected abstract IEnumerator CoWaitPlayer();
    }
}
