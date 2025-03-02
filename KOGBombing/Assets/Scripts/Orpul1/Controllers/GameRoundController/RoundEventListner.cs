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
        IRunGameEventAble runEvent;
        RaiseEventOptions options = new RaiseEventOptions();
        ETeam playerTeam;
        private void Start()
        {
            options.Receivers = ReceiverGroup.All;
            playerTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        }
        public void Initialize(IRunGameEventAble runEvent)
        {
            this.runEvent = runEvent;
        }

        public void BombEvent(EBombState bombState)
        {
            switch (bombState)
            {
                case EBombState.SET:
                    {
                        runEvent.RunEvent(RoundEndType.BOMBSET);
                    }
                    break;
                case EBombState.CLEAR: // ¹æ¾îÆÀ ½Â¸®
                    {
                        runEvent.RunEvent(RoundEndType.BOMBCLEAR);
                    }
                    break;
                case EBombState.EXPLOSION: //°ø°Ý ÆÀ ½Â¸®
                    {
                        runEvent.RunEvent(RoundEndType.BOMBEXPLOSION);
                    }
                    break;
            }
        }
        public void SetTeamCount(int teamType)
        {
            Debug.Log($"Decrease {(ETeam)teamType} Count");
            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERDIE, teamType, options, SendOptions.SendReliable);
        }
    }
}