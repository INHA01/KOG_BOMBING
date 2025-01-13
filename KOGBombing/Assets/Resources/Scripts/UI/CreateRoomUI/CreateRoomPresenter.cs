using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Orpul1
{
    public class CreateRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CreateRoomView view;
        CreateRoomModel model = new CreateRoomModel();
        public void onInputRoomName()
        {
            model.StbRoomName.Clear();
            model.StbRoomName.Append(view.InputRoomName.text);
        }
        public void onDropDPlayerCount()
        {
            model.StbPlayerCnt.Clear();
            model.StbPlayerCnt.Append(view.DropDPlayerCnt.value);
        }
        public CreateRoomModel GetRoomInfoModel()
        {
            return model;
        }
    }
}