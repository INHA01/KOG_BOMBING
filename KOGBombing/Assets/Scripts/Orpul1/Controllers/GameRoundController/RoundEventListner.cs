using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class RoundEventListner:MonoBehaviour,ISetTeamCountAble,IBombStateAble
    {
        IRunEventAble runEvent;
        RaiseEventOptions options = new RaiseEventOptions();
        private void Start()
        {
            options.Receivers = ReceiverGroup.All;
        }
        public void Initialize(IRunEventAble runEvent)
        {
            this.runEvent = runEvent;
        }

        public void BombEvent(EBombState bombState)
        {
            switch (bombState)
            {
                case EBombState.SET:
                    runEvent.RunEvent(EGameEvent.SETBOMB);
                    break;
                case EBombState.CLEAR:
                    {
                        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == ETeam.REDTEAM)
                        {
                            runEvent.RunEvent(EGameEvent.LOSS);
                        }
                        else
                        {
                            runEvent.RunEvent(EGameEvent.WIN);
                        }
                    }

                    break;
                case EBombState.EXPLOSION:
                    {
                        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == ETeam.REDTEAM)
                        {
                            runEvent.RunEvent(EGameEvent.WIN);
                        }
                        else
                        {
                            runEvent.RunEvent(EGameEvent.LOSS);
                        }
                    }
                    break;
            }
        }
        public void SetTeamCount(int teamType)
        {
            Debug.Log($"Decrease {(ETeam)teamType} Count");
            PhotonNetwork.RaiseEvent((int)EGameRound.EXTERMINATETEAM, teamType, options, SendOptions.SendReliable);
        }
    }
}