using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using WebSocketSharp;

namespace Orpul1
{
    public class ChatInputListner : MonoBehaviour
    {
        [SerializeField] bool isSendMessage = false;
        [SerializeField] TMP_InputField inputField;
        [SerializeField] InputActionAsset[] inputActions;
        InputAction extraMapInput;
        Action<int> setPlayerInput;
        Action<string> sendInputMessage;
        Action<EChatDelivery> changeSendMode;
        int sendMode = (int)EChatDelivery.ALL;
        private void Start()
        {
            ChatController chatController = GetComponent<ChatController>();
            setPlayerInput = chatController.SetBlockPlayerInput;
            sendInputMessage = chatController.SendChatMessage;
            changeSendMode = GetComponent<ChatUpdater>().SetSendModeText;
            inputField.enabled = false;
            inputField.DeactivateInputField();
            extraMapInput = inputActions[0].FindAction("ExtractMap");
        }
        private void ActivePlayerInput()
        {
            for (int i = 0; i < inputActions.Length; i++)
            {
                inputActions[i].Enable();
            }
        }
        private void DeactivePlayerInput()
        {
            for(int i=0; i<inputActions.Length; i++)
            {
                inputActions[i].Disable();
            }

            extraMapInput.Disable();
        }

        // >> : 대화 상대 변경(key : TAB)
        public void OnChatSendMode(InputValue input) 
        {
            if (inputField.text.Length > 1) return;
            sendMode++;
            sendMode = sendMode % (int)EChatDelivery.MAX;
            changeSendMode((EChatDelivery)sendMode);
        }

        // >> : 대화 시작, 종료(key : Enter, ESC)
        public void OnChat(InputValue input)
        {
            int value = (int)input.Get<float>();
            setPlayerInput(value);
            inputField.Select();
            if (value < 0)
            {
                inputField.enabled = false;
                inputField.DeactivateInputField();
                inputField.text = "";
                ActivePlayerInput();
            }
            else
            {
                inputField.enabled = true;
                inputField.ActivateInputField();
                DeactivePlayerInput();
            }
        }
        public void Submit()
        {
            inputField.ActivateInputField();
            if (inputField.text.IsNullOrEmpty()) return;
            sendInputMessage?.Invoke(inputField.text);
            inputField.text = "";
        }
        public void OnIgnoreTab(string text)
        {
            if (text != "\t") return;
            inputField.text = "";
        }
    }

}
