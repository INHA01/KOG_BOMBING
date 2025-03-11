using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class RoomListController : MonoBehaviourPunCallbacks
    {
        [SerializeField] GameObject roomPanelPref;
        [SerializeField] Transform trRoomListPanel;
        [SerializeField] MatchData matchData;

        Dictionary<string, DisplayRoomPresenter> dictRoomInfo = new Dictionary<string, DisplayRoomPresenter>();

        public override void OnRoomListUpdate(List<RoomInfo> roomList)
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName) return;
            UpdateInfo(roomList);
        }
        public override void OnLeftRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName) return;
            RemoveAllInfo();
        }
        private void UpdateInfo(List<RoomInfo> roomList)
        {
            for (int i = 0; i < roomList.Count; i++)
            {
                if (!dictRoomInfo.ContainsKey(roomList[i].Name))
                {
                    DisplayRoomPresenter presenter = Instantiate(roomPanelPref, trRoomListPanel).GetComponent<DisplayRoomPresenter>();
                    presenter.Init(roomList[i]);
                    dictRoomInfo.Add(roomList[i].Name, presenter);
                }
                else
                {
                    if (roomList[i].RemovedFromList)
                    {
                        Destroy(dictRoomInfo[roomList[i].Name].gameObject);
                        dictRoomInfo.Remove(roomList[i].Name);
                    }
                    else
                    {
                        dictRoomInfo[roomList[i].Name].SetRoomInfo(roomList[i]);
                    }
                }
            }
        }

        private void RemoveAllInfo()
        {
            List<string> keyList = new List<string>(dictRoomInfo.Keys);
            for (int i = 0; i < keyList.Count; i++)
            {
                Destroy(dictRoomInfo[keyList[i]].gameObject);
                dictRoomInfo.Remove(keyList[i]);
            }
        }

    }
}