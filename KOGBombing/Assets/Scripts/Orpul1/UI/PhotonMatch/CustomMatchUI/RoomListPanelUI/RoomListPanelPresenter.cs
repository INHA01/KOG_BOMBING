using Photon.Pun;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;

    private void Start()
    {
        view.backgroundPanelObj.SetActive(false);
        view.roomListPanelObj.SetActive(false);
    }
    public void ActiveUIPanel()
    {
        view.backgroundPanelObj.SetActive(true);
        view.roomListPanelObj.SetActive(true);
    }
    public void OnLeaveMatchBtn()
    {
        view.backgroundPanelObj.SetActive(false);
        view.roomListPanelObj.SetActive(false);
    }
    public void OnCreatRoomBtn()
    {
        view.createPanelObj.SetActive(true);
    }
}
