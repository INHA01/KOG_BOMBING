using Photon.Pun;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;

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
        view.btnRandomMatch.interactable = true;
        view.btnCustomMatch.interactable = true;
        view.roomListPanelObj.SetActive(false);
        PhotonNetwork.LeaveLobby();
    }
    public void OnCreatRoomBtn()
    {
        view.createPanelObj.SetActive(true);
    }
}
