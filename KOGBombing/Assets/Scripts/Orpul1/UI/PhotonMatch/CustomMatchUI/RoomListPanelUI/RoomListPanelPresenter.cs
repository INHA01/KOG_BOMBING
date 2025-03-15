using Orpul1;
using Photon.Pun;
using System.Collections;
using Unity.VisualScripting;
using UnityEngine;

public class RoomListPanelPresenter : MonoBehaviour
{
    [SerializeField]
    RoomListPanelView view;
    [SerializeField]
    RoomListPanelModel model;
    
    private void OnEnable()
    {
        UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVEROOMLISTPANEL,ActiveUIPanel);
        UIEventBus.Subscribe(UIEventBus.UIEventType.DEACTIVEROOMLISTPANEL,DeactiveUIPanel);
    }
    private void OnDisable()
    {
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVEROOMLISTPANEL, ActiveUIPanel);
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.DEACTIVEROOMLISTPANEL, DeactiveUIPanel);
    }
    private void Start()
    {
        model.Init(UpdateUI);
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(false);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(false);
    }
    public void ActiveUIPanel()
    {
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(true);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(true);
    }
    public void DeactiveUIPanel()
    {
        model.TurnBackScreen();
    }
    void UpdateUI()
    {
        view.panels[(int)ERoomListPanel.BACKGROUND].SetActive(false);
        view.panels[(int)ERoomListPanel.ROOMLIST].SetActive(false);
    }
    public void OnLeaveMatchBtn()
    {
        DeactiveUIPanel();
        view.btnSelectMode.interactable = true;
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
    public void OnCreatRoomBtn()
    {
        view.panels[(int)ERoomListPanel.CREATEPANEL].SetActive(true);
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
}
