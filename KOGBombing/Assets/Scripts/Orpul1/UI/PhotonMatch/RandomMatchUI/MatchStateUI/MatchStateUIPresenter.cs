using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchStateUIPresenter : MonoBehaviour
{
    [SerializeField] MatchStateUIView view;
    private void OnEnable()
    {
        UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVEWAITMATCHPANEL, ActivePanel);
        UIEventBus.Subscribe(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL, DeactivePanel);
    }
    private void OnDisable()
    {
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVEWAITMATCHPANEL, ActivePanel);
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL, DeactivePanel);
    }
    public void Initialize()
    {
        view.waitMatchPanel.SetActive(true);
    }
    public void ActivePanel()
    {
        view.waitMatchPanel.SetActive(true);
    }
    public void DeactivePanel()
    {
        view.waitMatchPanel.SetActive(false);
    }
}
