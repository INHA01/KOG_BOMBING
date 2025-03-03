using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchStateUIPresenter : MonoBehaviour
{
    [SerializeField] MatchStateUIView view;
    [SerializeField] MatchStateUIModel model;
    private void Awake()
    {
        model.Initialize(UpdateUI);
    }
    private void OnEnable()
    {
        UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVEWAITMATCHPANEL, ActivePanel);
        UIEventBus.Subscribe(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL, DeactivePanel);
    }
    private void OnDisable()
    {
        model.AbortRoundAni();
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVEWAITMATCHPANEL, ActivePanel);
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL, DeactivePanel);
    }
    public void Initialize()
    {
        view.waitMatchPanel.SetActive(true);
    }
    public void ActivePanel()
    {
        model.ProcessRoundAni();
        view.waitMatchPanel.SetActive(true);
    }
    public void DeactivePanel()
    {
        view.waitMatchPanel.SetActive(false);
    }
    public void UpdateUI()
    {
        view.matchingImg.fillAmount = model.CountValue;
    }
}
