using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.UIElements;
using WebSocketSharp;

namespace Orpul1
{
    public class ChatInputListner : MonoBehaviour
    {
        [SerializeField] bool isSendMessage = false;
        [SerializeField] TMP_InputField inputField;
        [SerializeField] InputActionAsset[] inputActions;
        InputAction extraMap;
        Action<int> setPlayerInput;
        Action<string> sendInputMessage;

        private void Start()
        {
            ChatController chatController = GetComponent<ChatController>();
            setPlayerInput = chatController.SetBlockPlayerInput;
            sendInputMessage = chatController.SendChatMessage;
            inputField.enabled = false;
            inputField.DeactivateInputField();
            extraMap = inputActions[0].FindAction("ExtractMap");
        }
        private void ActivePlayerInput()
        {
            for (int i = 0; i < inputActions.Length; i++)
            {
                inputActions[i].Enable();
            }
            extraMap.Enable();
        }
        private void DeactivePlayerInput()
        {
            for(int i=0; i<inputActions.Length; i++)
            {
                inputActions[i].Disable();
            }
            extraMap.Disable();
        }
        public void OnChat(InputValue input)
        {
            int value = (int)input.Get<float>();
            setPlayerInput(value);
            inputField.Select();
            Debug.Log(value);
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
    }

}
