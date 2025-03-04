using Orpul1;
using Photon.Pun;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;

    private void OnEnable()
    {
        UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVEROOMLISTPANEL,ActiveUIPanel);
    }
    private void OnDisable()
    {
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVEROOMLISTPANEL, ActiveUIPanel);
    }
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
        view.btnSelectMode.interactable = true;
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
    }
    public void OnCreatRoomBtn()
    {
        view.createPanelObj.SetActive(true);
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
    }
}
