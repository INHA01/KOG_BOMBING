using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

namespace Orpul1
{
    public enum EChatDelivery
    {
        ALL,
        TEAM,
    }
    public class ChatUpdater : MonoBehaviour
    {
        RaiseEventOptions options = new RaiseEventOptions();
        SendOptions sendOptions = new SendOptions();
        [SerializeField] FactoryBase factory;
        [SerializeField] Color[] teamColor;
        private void Awake()
        {
            options.Receivers = ReceiverGroup.All;
            sendOptions.DeliveryMode = DeliveryMode.Reliable;
            sendOptions.Reliability = true;
        }
        private void OnEnable()
        {
            UnsubscribeEvent();
            SubscribeEvent();
        }
        private void OnDisable()
        {
            UnsubscribeEvent();
        }
        private void SubscribeEvent()
        {
            PhotonNetwork.NetworkingClient.EventReceived += PunChat;
        }
        private void UnsubscribeEvent()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= PunChat;
        }
        public void SendChat(string message)
        {
            string nickname = "["+PhotonNetwork.NickName + "]: ";
            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            object[] sendDatas = new object[] { mTeam, nickname + message };
            PhotonNetwork.RaiseEvent((int)PunEventType.SENDCHAT, sendDatas, options, sendOptions);
        }
        //ETeam, int, string
        private void PunChat(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.SENDCHAT) return;
            object[] receiveDatas = (object[])punEvent.CustomData;
            ETeam team = (ETeam)receiveDatas[0];
            string message = (string)receiveDatas[1];

            TextMeshProUGUI chatTextUI = factory.GetPrefab<TextMeshProUGUI>(0);
            chatTextUI.color = teamColor[(int)team];
            chatTextUI.text = message;
        }
    }

}
