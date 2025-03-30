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
        [SerializeField] Canvas chatCanvas;
        [SerializeField] Image[] rectImages;
        Action<string> sendMessage;
        [SerializeField] Color32[] rectColorValues = new Color32[2];
        private void Reset()
        {
            chatCanvas = GetComponent<Canvas>();
        }
        private void Start()
        {
            sendMessage = GetComponent<ChatUpdater>().SendChat;
            chatPanel.DOSizeDelta(chatSize[1], 0.5f);
            ChangeRectImageAlpha(0);
        }
        public void SetCanvasOrderLayer(int layer)
        {
            chatCanvas.sortingOrder = layer;
        }
        public void SetBlockPlayerInput(int keyType)
        {
            if (keyType == 1)
            {
                chatPanel.DOSizeDelta(chatSize[0], 0.5f);
                ChangeRectImageAlpha(1);
            }
            else if (keyType == -1)
            {
                chatPanel.DOSizeDelta(chatSize[1], 0.5f);
                ChangeRectImageAlpha(0);
            }
        }
        private void ChangeRectImageAlpha(int index)
        {

            for (int i = 0; i < rectImages.Length; i++)
            {
                rectImages[i].DOColor(rectColorValues[index], 0.5f);
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
