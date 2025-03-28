using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using Photon.Realtime;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using ExitGames.Client.Photon;
using System;
using BAEK;
namespace Orpul1
{
    public enum EGameState
    {
        START,
        WAITPLAYERS,
        SELECT,
        SPAWNPLAYER,
        ROUNDWAIT,
        GAMESTART,
        ROUNDENDWAIT,
        SWITCHTEAMROLL,
        GAMEEND,
        END,
    }
    public enum EGameEvent
    {
        WIN,
        LOSS,
        DOOROPEN,
        LASTROUND,
        SETBOMB,
        SWITCHROLL,
    }
    

    public class GameDirector : MonoBehaviourPunCallbacks
    {
        public static int blueScore = 0;
        public static int redScore = 0;
        Dictionary<int, IState> dicGameState = new Dictionary<int, IState>();
        IState curState;
        public IState CurState { get { return curState; } }
        private void Awake()
        {
            InitializeState();
        }
        private void Start()
        {

            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            int playerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            ISetPunInfo punInfo = Managers.UI.GetPopupUI<CrossHairController>(UIKEY.CrossHair);
            punInfo.SetPunInfo(mTeam, playerIndex);
        }
        private void InitializeState()
        {
            IState[] states = GetComponents<IState>();

            for (int i=(int)EGameState.START+1; i<(int)EGameState.END; i++)
            {
                IState state = states[i-1];
                state.Initialize(TransitionState,GetComponent<GameProcessData>());
                dicGameState.Add(i, state);
            }
            TransitionState((int)EGameState.WAITPLAYERS);
        }
        private void Update()
        {
            curState.UpdateState();
        }
        private void TransitionState(int stateType)
        {
            if (curState != null)
            {
                curState.ExitState();
            }
            curState = dicGameState[stateType];
            curState.EnterState();
        }
    }
}
