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

        Dictionary<string, DisplayRoomPresenter> dicRoomInfo = new Dictionary<string, DisplayRoomPresenter>();

        public override void OnRoomListUpdate(List<RoomInfo> roomList)
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            UpdateInfo(roomList);
        }
        public override void OnLeftRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            RemoveAllInfo();
        }
        private void UpdateInfo(List<RoomInfo> roomList)
        {
            for (int i = 0; i < roomList.Count; i++)
            {
                if (!dicRoomInfo.ContainsKey(roomList[i].Name))
                {
                    DisplayRoomPresenter presenter = Instantiate(roomPanelPref, trRoomListPanel).GetComponent<DisplayRoomPresenter>();
                    presenter.Init(roomList[i]);
                    dicRoomInfo.Add(roomList[i].Name, presenter);
                }
                else
                {
                    if (roomList[i].RemovedFromList) continue;
                    Destroy(dicRoomInfo[roomList[i].Name].gameObject);
                    dicRoomInfo.Remove(roomList[i].Name);
                }
            }
        }

        private void RemoveAllInfo()
        {
            List<string> keyList = new List<string>(dicRoomInfo.Keys);
            for (int i = 0; i < keyList.Count; i++)
            {
                Destroy(dicRoomInfo[keyList[i]].gameObject);
                dicRoomInfo.Remove(keyList[i]);
            }
        }

    }
}