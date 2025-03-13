using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

public class KillLogUIPresenter : PooledObject
{
    [SerializeField] KillLogUIView view;
    [SerializeField] KillLogUIModel model;

    public void Initialize()
    {
        model.Initialize(UpdateUI);
    }
    public void SetKillLog(KillLogPlayer[] logInfos)
    {
        view.killLogPanel.SetActive(true);
        model.SetPlayerInfo(logInfos);
        StartCoroutine("CoDeactiveUI");
    }
    public void UpdateUI()
    {
        for(int i=0; i<(int)EPlayerLogType.END; i++)
        {
            int colorIndex = (int)model.playerTeam[i];
            view.tmpPlayerNicknames[i].text = model.playerNicknames[i].ToString();
            view.panelImages[i].color = model.backgroundColors[colorIndex];
        }
    }
    private IEnumerator CoDeactiveUI()
    {
        float time = Time.time + model.deactiveTime;
        while(time > Time.time) yield return null;
        view.killLogPanel.SetActive(false);
        Release();
    }
}
