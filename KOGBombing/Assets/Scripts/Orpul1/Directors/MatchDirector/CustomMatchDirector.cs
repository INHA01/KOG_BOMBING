using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);

        [SerializeField]
        MatchUIController matchUIController;
        bool isCustomMatch = false;
        
        public override void Match()
        {
            isCustomMatch = true;
            matchUIController.CustomListUIActive();
            base.Match();
        }
        public void OnLeftLobbyBtn()
        {
            isStopMatch = true;
            isCustomMatch = false;
            if (PhotonNetwork.InLobby)
                PhotonNetwork.LeaveLobby();
        }
       
        public override void OnLeftLobby()
        {
            Debug.Log("LeftLobby");
        }
        public override void OnLeftRoom()
        {
            Debug.Log("LeftRoom");
        }

        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                Debug.Log($"CustomMatch JoinRoom");
                base.OnJoinedRoom();
                matchUIController.CustomRoomUIActive();
                matchUIController.UpdateRoomOwner();
            }
        }

        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (isCustomMatch)
            {
                base.OnPlayerLeftRoom(otherPlayer);
                matchUIController.UpdateRoomOwner();
            }
        }

        protected override IEnumerator CoWaitMatch()
        {
            Debug.Log($"isStopMatch {isStopMatch}");
            float span = Time.time + updateDelay;
            while (span > Time.time)
            {
                if (isStopMatch) yield break;
                yield return null;
            }
            Debug.Log("lobby Match");
            PhotonNetwork.JoinLobby(customLobby);
        }

        protected override IEnumerator CoStartDelay()
        {
            matchUIController.DeactiveCustomRoomBtn();
            float delayTime = Time.time + 3f;

            while (Time.time < delayTime) yield return null;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            PhotonNetwork.IsMessageQueueRunning = true;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            Managers.UI.DestroyAllSceneUI();
            PhotonNetwork.LoadLevel(3);
            //LoadingSceneManager.LoadScene("TestGame");

        }
    }
}