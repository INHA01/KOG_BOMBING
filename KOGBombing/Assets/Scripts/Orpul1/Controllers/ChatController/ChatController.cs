using Photon.Pun;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

namespace Orpul1
{
    public class ChatController : MonoBehaviour
    {
        [SerializeField] Image chatPanel;
        [SerializeField] BadWordData badWordData;
        Action<string> sendMessage;
        private void Start()
        {
            sendMessage = GetComponent<ChatUpdater>().SendChat;
        }
        public void SetBlockPlayerInput(bool isBlock)
        {

        }
        public void SendChatMessage(string message)
        {
            Debug.Log(message);
            sendMessage?.Invoke(DoFilterBadword(message));
        }

        private string DoFilterBadword(string message)
        {
            return badWordData.FilterMessage(message);
        }

    }

}
