using Photon.Pun;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
public class CustomRoomPresenter : MonoBehaviour
{
    [SerializeField]
    CustomRoomView view;

    private void Start()
    {
        view.customRoomPanel.SetActive(false);
    }
    public void ActiveUIPanel()
    {
        view.customRoomPanel.SetActive(true);
    }
    public void OnLeaveRoomBtn()
    {
        view.customRoomPanel.SetActive(false);
        view.customRoomListPanel.SetActive(false);
        Debug.Log("Click Leave Room Button");
        PhotonNetwork.LeaveRoom();
    }
    public void OnStartRoomBtn()
    {
        PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RoomState", "Start" } });
    }
    public void OnSwapTeamBtn()
    {
        if ((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == "RT") 
        {
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", "BT" } });
            Debug.Log("Swap Blue TEAM");
        }
        else
        {
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", "RT" } });
            Debug.Log("Swap Red TEAM");
        }
    }
    
    public void SetRoomOwner()
    {
        if (PhotonNetwork.IsMasterClient)
        {
            view.btnStartGame.interactable = true;
        }
        else
        {
            view.btnStartGame.interactable = false;
        }
    }
}
