using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Orpul1
{
    public class ChatInputListner : MonoBehaviour
    {
        [SerializeField] bool isSendMessage = false;
        [SerializeField] TextMeshProUGUI inputMessage;
        [SerializeField] TMP_InputField inputField;
        Action<bool> setPlayerInput;
        Action<string> sendInputMessage;

        private void Start()
        {
            ChatController chatController = GetComponent<ChatController>();
            setPlayerInput = chatController.SetBlockPlayerInput;
            sendInputMessage = chatController.SendChatMessage;
        }
        public void OnChat(InputValue input)
        {
            setPlayerInput(isSendMessage);
            SetInputMessage();
        }
        public void SetInputMessage()
        {
            if (!isSendMessage) return;
            sendInputMessage?.Invoke(inputField.text);
            inputField.text = "";
        }
    }

}
