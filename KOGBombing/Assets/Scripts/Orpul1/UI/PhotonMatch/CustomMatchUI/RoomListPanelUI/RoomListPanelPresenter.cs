using Photon.Pun;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;
    RoomListPanelModel model;

    public void OnLeaveMatchBtn()
    {
        view.roomListPanelObj.SetActive(false);
        PhotonNetwork.LeaveLobby();
    }
    public void OnCreatRoomBtn()
    {
        view.createPanelObj.SetActive(true);
    }
}
