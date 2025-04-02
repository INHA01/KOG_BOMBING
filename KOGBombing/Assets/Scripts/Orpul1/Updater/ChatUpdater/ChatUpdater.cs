using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace Orpul1
{
    public enum EChatDelivery
    {
        TEAM,
        ALL,
        MAX,
    }
    public class ChatUpdater : ObjectPool
    {
        RaiseEventOptions options = new RaiseEventOptions();
        SendOptions sendOptions = new SendOptions();
        [SerializeField] FactoryBase factory;
        [SerializeField] Color[] teamColor;
        [SerializeField] TextMeshProUGUI sendModetext;
        [SerializeField] string[] sendTypeText;
        [SerializeField] Transform uiParent;
        EChatDelivery sendMode = EChatDelivery.ALL;
        int pooluseCount = 0;
        private void Awake()
        {
            options.Receivers = ReceiverGroup.All;
            sendOptions.DeliveryMode = DeliveryMode.Reliable;
            sendOptions.Reliability = true;
            SetSendModeText(sendMode);
            parent = uiParent;
        }
        private void OnEnable()
        {
            UnsubscribeEvent();
            SubscribeEvent();
            pooluseCount = 0;
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
        public void SetSendModeText(EChatDelivery sendMode)
        {
            int textColor = GetColorType(sendMode);

            sendModetext.text = sendTypeText[(int)sendMode];
            sendModetext.color = teamColor[textColor];
            this.sendMode = sendMode;
        }
        public void SendChat(string message)
        {
            string nickname = "["+PhotonNetwork.NickName + "]: ";
            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            object[] sendDatas = new object[] { sendMode, mTeam, nickname + message };
            PhotonNetwork.RaiseEvent((int)PunEventType.SENDCHAT, sendDatas, options, sendOptions);
        }
        private int GetColorType(EChatDelivery sendMode)
        {
            int textColor = (int)sendMode + 1 ;
            if (sendMode == EChatDelivery.TEAM)
                textColor = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            return textColor;
        }

        private void PunChat(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.SENDCHAT) return;

            object[] receiveDatas = (object[])punEvent.CustomData;
            EChatDelivery sendMode = (EChatDelivery)receiveDatas[0];
            ETeam team = (ETeam)receiveDatas[1];

            if (!CanRecievChat(sendMode, team))  return;

            int textColor = GetColorType(sendMode);
            string message = (string)receiveDatas[2];

            EnableChatUI(message, textColor);
        }
        private void EnableChatUI(string message, int textColor)
        {
            PooledObject chatUI = GetPooledObject();
            TextMeshProUGUI chatTextUI = chatUI.GetComponent<TextMeshProUGUI>();
            chatTextUI.transform.SetParent(null);
            chatTextUI.color = teamColor[textColor];
            chatTextUI.text = message;
            chatTextUI.transform.SetParent(uiParent);
            ReturnToPool(chatUI);
            chatTextUI.transform.localScale = Vector3.one;
            chatTextUI.gameObject.SetActive(true);
        }
        private bool CanRecievChat(EChatDelivery sendMode, ETeam team)
        {
            if (sendMode == EChatDelivery.ALL) 
                return true;

            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            if(team == mTeam) 
                return true;

            return false;
        }
    }

}
