using DG.Tweening;
using Photon.Pun;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Orpul1
{
    public class ChatController : UIPopup
    {
        [SerializeField] RectTransform chatPanel;
        [SerializeField] BadWordData badWordData;
        [SerializeField] GameObject chatUI;
        [SerializeField] Vector2[] chatSize;
        Action<string> sendMessage;
        private void Start()
        {
            sendMessage = GetComponent<ChatUpdater>().SendChat;
            chatPanel.DOSizeDelta(chatSize[1], 0.5f);
            chatUI.SetActive(false);
        }
        public void SetBlockPlayerInput(int keyType)
        {
            if (keyType == 1)
            {
                chatPanel.DOSizeDelta(chatSize[0], 0.5f);
            }
            else if (keyType == -1)
            {
                chatPanel.DOSizeDelta(chatSize[1], 0.5f);
            }
        }
        public void SendChatMessage(string message)
        {
            Debug.Log($"{message} {message.Length}");
            sendMessage?.Invoke(DoFilterBadword(message));
        }

        private string DoFilterBadword(string message)
        {
            return badWordData.FilterMessage(message);
        }

        
    }

}
