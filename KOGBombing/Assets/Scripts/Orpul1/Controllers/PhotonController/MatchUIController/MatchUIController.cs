using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchUIController : MonoBehaviour
{
    [SerializeField]
    CustomRoomPresenter customRoomUI;
    [SerializeField]
    RoomListPanelPresenter roomListUI;
    public void CustomListUIActive()
    {
        roomListUI.ActiveUIPanel();
    }
    public void CustomRoomUIActive()
    {
        customRoomUI.ActiveUIPanel();
    }
    public void UpdateRoomOwner()
    {
        customRoomUI.SetRoomOwner();
    }
}
