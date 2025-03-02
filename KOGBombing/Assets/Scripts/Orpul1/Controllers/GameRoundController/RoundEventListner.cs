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
        private void OnEnable()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= PunBombEvent;
            PhotonNetwork.NetworkingClient.EventReceived += PunBombEvent;
        }
        private void OnDisable()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= PunBombEvent;
        }
        public void Initialize(IRunGameEventAble runEvent)
        {
            this.runEvent = runEvent;
        }

        public void BombEvent(EBombState bombState)
        {
            PhotonNetwork.RaiseEvent((int)PunEventType.RUNEVENT, bombState, options, SendOptions.SendReliable);
        }
        private void PunBombEvent(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.RUNEVENT) return;
            
            runEvent.RunEvent((RoundEndType)punEvent.CustomData + 1);
        }
        public void SetTeamCount(int teamType)
        {
            Debug.Log($"Decrease {(ETeam)teamType} Count");
            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERDIE, teamType, options, SendOptions.SendReliable);
        }
    }
}