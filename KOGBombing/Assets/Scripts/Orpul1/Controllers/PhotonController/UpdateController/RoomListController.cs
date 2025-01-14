using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class RoomListController : PhotonUpdateController<List<RoomInfo>>
    {
        Dictionary<string, DisplayRoomPresenter> dicRoomInfo = new Dictionary<string, DisplayRoomPresenter>();
        
        [SerializeField] GameObject roomPanelPref;
        [SerializeField] Transform trRoomListPanel;
        public override void UpdateInfo(List<RoomInfo> roomList)
        {
            for (int i = 0; i < roomList.Count; i++)
            {
                if (dicRoomInfo.ContainsKey(roomList[i].Name))
                {
                    if (roomList[i].RemovedFromList)
                    {
                        Destroy(dicRoomInfo[roomList[i].Name].gameObject);
                        dicRoomInfo.Remove(roomList[i].Name);
                    }
                }
                else
                {
                    // TODO: 룸 정보 입력 후 저장
                    DisplayRoomPresenter presenter = Instantiate(roomPanelPref, trRoomListPanel).GetComponent<DisplayRoomPresenter>();
                    presenter.SetServerInfo(roomList[i]);
                    dicRoomInfo.Add(roomList[i].Name, presenter);
                }
            }
        }
    }
}