using Photon.Pun;
using System.Text;
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
        StringBuilder curTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);
        StringBuilder changeTeam = new StringBuilder(); 
        if (curTeam.ToString() == "RT")
            changeTeam.Append("BT");
        else
            changeTeam.Append("RT");

        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", changeTeam.ToString() } });
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
