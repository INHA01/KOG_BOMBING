using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using WebSocketSharp;

namespace Orpul1
{
    enum EActiveInput
    {
        Chat,
        ChatSendMode,
        END,
    }
    public class ChatInputListner : MonoBehaviour
    {
        [SerializeField] bool isSendMessage = false;
        [SerializeField] TMP_InputField inputField;
        [SerializeField] InputActionAsset[] inputActions;
        List<InputAction> activeInputList = new List<InputAction>();
        InputAction extraMapInput;
        Action<int> setPlayerInput;
        Action<string> sendInputMessage;
        Action<EChatDelivery> changeSendMode;
        bool isPressSendModeKey = false;
        int sendMode = (int)EChatDelivery.ALL;
        private void Start()
        {
            ChatController chatController = GetComponent<ChatController>();
            setPlayerInput = chatController.SetBlockPlayerInput;
            sendInputMessage = chatController.SendChatMessage;
            changeSendMode = GetComponent<ChatUpdater>().SetSendModeText;
            inputField.enabled = false;
            inputField.DeactivateInputField();
            for (int i = 0; i < (int)EActiveInput.END; i++) 
            {
                EActiveInput eActiveInput = (EActiveInput)i;
                activeInputList.Add(inputActions[0].FindAction(eActiveInput.ToString()));
            }
            extraMapInput = inputActions[0].FindAction("ExtractMap");
        }
        private void ActivePlayerInput()
        {
            for (int i = 0; i < inputActions.Length; i++)
            {
                inputActions[i].Enable();
            }
            extraMapInput.Enable();
        }
        private void DeactivePlayerInput()
        {
            for(int i=0; i<inputActions.Length; i++)
            {
                inputActions[i].Disable();
            }
            for (int i = 0; i < activeInputList.Count; i++)
                activeInputList[i].Enable();

            extraMapInput.Disable();
        }
        public void OnChatSendMode(InputValue input)
        {
            if (inputField.text.Length > 1) return;
            sendMode++;
            sendMode = sendMode % (int)EChatDelivery.MAX;
            changeSendMode((EChatDelivery)sendMode);
        }
        public void OnChat(InputValue input)
        {
            int value = (int)input.Get<float>();
            setPlayerInput(value);
            inputField.Select();
            if (value < 0)
            {
                inputField.enabled = false;
                inputField.DeactivateInputField();
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
