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
        TEAM,
        ALL,
        MAX,
    }
    public class ChatUpdater : MonoBehaviour
    {
        RaiseEventOptions options = new RaiseEventOptions();
        SendOptions sendOptions = new SendOptions();
        [SerializeField] FactoryBase factory;
        [SerializeField] Color[] teamColor;
        [SerializeField] List<GameObject> chatLogList = new List<GameObject>();
        [SerializeField] TextMeshProUGUI sendModetext;
        [SerializeField] string[] sendTypeText;
        EChatDelivery sendMode = EChatDelivery.ALL;
        private void Awake()
        {
            options.Receivers = ReceiverGroup.All;
            sendOptions.DeliveryMode = DeliveryMode.Reliable;
            sendOptions.Reliability = true;
            SetSendModeText(sendMode);
        }
        private void OnEnable()
        {
            UnsubscribeEvent();
            SubscribeEvent();
        }
        private void OnDisable()
        {
            UnsubscribeEvent();
            DeleteAllChat();
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
        //ETeam, int, string
        private void PunChat(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.SENDCHAT) 
                return;

            object[] receiveDatas = (object[])punEvent.CustomData;
            EChatDelivery sendMode = (EChatDelivery)receiveDatas[0];
            ETeam team = (ETeam)receiveDatas[1];
            if (!CanRecievChat(sendMode, team)) 
                return;
            int textColor = GetColorType(sendMode);
            string message = (string)receiveDatas[2];

            TextMeshProUGUI chatTextUI = factory.GetPrefab<TextMeshProUGUI>(0);
            chatTextUI.color = teamColor[textColor];
            chatTextUI.text = message;
            chatLogList.Add(chatTextUI.gameObject);
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
        private void DeleteAllChat()
        {
            for(int i=0; i<chatLogList.Count; i++)
            {
                Destroy(chatLogList[i]);
            }
        }
    }

}
