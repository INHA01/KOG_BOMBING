using System.Collections.Generic;
using UnityEngine;

public class RoomListModel:MonoBehaviour
{
    public GameObject RoomPanelPref;
    public Transform trRoomListPanel;
    public Dictionary<string, CustomRoomPresenter> DicRoomInfo = new Dictionary<string, CustomRoomPresenter>();
}