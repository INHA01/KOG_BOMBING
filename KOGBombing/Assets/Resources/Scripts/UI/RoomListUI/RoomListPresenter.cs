using Photon.Realtime;
using System.Collections.Generic;
using System.Text;
using UnityEngine;


namespace Orpul1
{
    public class RoomListPresenter : MonoBehaviour
    {
        [SerializeField]
        RoomListModel model;
        [SerializeField]
        RoomListView view;

        public void UpdateRoomList(List<RoomInfo> roomList)
        {
            for (int i = 0; i < roomList.Count; i++)
            {
                if (roomList[i].RemovedFromList)
                {
                    Destroy(model.DicRoomInfo[roomList[i].Name].gameObject);
                    model.DicRoomInfo.Remove(roomList[i].Name);
                }
                else if (model.DicRoomInfo.ContainsKey(roomList[i].Name))
                {
                    // TODO: 룸 정보 변경
                    model.DicRoomInfo[roomList[i].Name].SetPlayerCount(new StringBuilder(roomList.Count.ToString()));
                }
                else
                {
                    // TODO: 룸 정보 입력 후 저장
                    CustomRoomPresenter presenter = Instantiate(model.RoomPanelPref, model.trRoomListPanel).GetComponent<CustomRoomPresenter>();
                    presenter.SetServerInfo(roomList[i]);
                    model.DicRoomInfo.Add(roomList[i].Name, presenter);
                }
            }
        }
        public void OnQuitBtn()
        {
            //TODO: 룸 리스트 나가기 버튼 액션
        }

        public void OnCreateRoomBtn()
        {
            //TODO: 방 생성 버튼 액션
        }
    }
}