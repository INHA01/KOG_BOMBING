using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchingUIPresenter : MonoBehaviour
{
    [SerializeField]
    MatchingUIModel model;
    [SerializeField]
    MatchingUIView view;
    private void OnEnable()
    {
        UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVEMATCHINGPANEL, ActiveMatchingUI);
    }
    private void OnDisable()
    {
        UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVEMATCHINGPANEL, ActiveMatchingUI);
    }
    public void ActiveMatchingUI()
    {
        view.matchingPanel.SetActive(true);
        model.RunCountTime();
    }

    public void UpdateUI()
    {
        view.matchingImage.fillAmount = model.CountValue;
    }
}
