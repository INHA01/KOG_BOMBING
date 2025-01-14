using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class CreateRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CreateRoomView view;
        CreateRoomModel model = new CreateRoomModel();
        public void InputFieldSetRoomName()
        {
            model.StbRoomName.Clear();
            model.StbRoomName.Append(view.InputRoomName.text);
        }
        public void DropDownSetPlayerCnt()
        {
            model.StbPlayerCnt.Clear();
            model.StbPlayerCnt.Append(view.DropDPlayerCnt.value);
        }
        public void OnQuitBtn()
        {
            view.popupObj.SetActive(false);
        }
        public StringBuilder GetRoomName()
        {
            StringBuilder result = new StringBuilder(view.InputRoomName.text.ToString());
            return result;
        }
        public int GetMaxPlayer()
        {
            int maxPlayer = 0;
            int.TryParse(view.DropDPlayerCnt.ToString(), out maxPlayer);
            return maxPlayer;
        }
    }
}