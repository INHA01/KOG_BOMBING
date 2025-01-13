using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class RoomListModel : MonoBehaviour
    {
        public GameObject RoomPanelPref;
        public Transform trRoomListPanel;
        public Dictionary<string, CustomRoomPresenter> DicRoomInfo = new Dictionary<string, CustomRoomPresenter>();
    }
}
