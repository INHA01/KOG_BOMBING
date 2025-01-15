using Photon.Pun;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;
    RoomListPanelModel model;

    private void Start()
    {
        view.roomListPanelObj.SetActive(false);
    }
    public void OnActivePopupBtn()
    {
        view.roomListPanelObj.SetActive(true);
    }
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
