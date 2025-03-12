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
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(false);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(false);
    }
    public void ActiveUIPanel()
    {
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(true);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(true);
    }
    public void OnLeaveMatchBtn()
    {
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(false);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(false);
        view.btnSelectMode.interactable = true;
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
    public void OnCreatRoomBtn()
    {
        view.panels[(int)ERoomListPanel.CREATEPANEL].SetActive(true);
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
}
