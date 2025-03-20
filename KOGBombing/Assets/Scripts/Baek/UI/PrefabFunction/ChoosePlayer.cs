using Orpul1;
using Photon.Pun;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ChoosePlayer : Subject
{
    [SerializeField] protected Transform teamIconBack;
    [SerializeField] TextMeshProUGUI characterName;
    [SerializeField] TextMeshProUGUI teamType;
    [SerializeField] TextMeshProUGUI countDownText;
    public Semin.CharacterType type;
    public override void Notify(int index)
    {
        base.Notify(index);
        SetCharacterName(index);
    }
    public virtual void Init()
    {
        ETeam eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        if (eTeam == ETeam.BLUETEAM)
        {
            Color32 weekBlue = new Color32(0, 0, 255, 60);
            teamType.color = Color.blue;
            teamType.colorGradient = new VertexGradient(Color.blue, Color.blue, weekBlue, weekBlue);
            teamType.text = "수비";
        }
        else
        {
            Color32 weekRed = new Color32(255, 0, 0, 60);
            teamType.color = Color.red;
            teamType.colorGradient = new VertexGradient(Color.red, Color.red, weekRed, weekRed);
            teamType.text = "공격";
        }
        GameObject go = null;
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/ChoosePlayer/ChooseAvatar");
        go.GetComponent<ChooseAvatar>().SetSubject(this, true);

        Notify((int)type);
        //SetIcon(true);
        StartCoroutine(CountDown());
    }
    public virtual void SetIcon(bool isMine)
    {
        GameObject go = null;
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/ChoosePlayer/IconBack", teamIconBack);
        if(isMine)
        {
            go.GetComponent<ChooseAvatarIcon>().SetSubject(this , true);
        }
    }
    public void SetCharacterName(int index)
    {
        type = (Semin.CharacterType)index;
        characterName.text = type.ToString();
    }
    public void Spawn()
    {
        EventBusSystem.Publish();
        Notify();
        RemoveAllObserver();
        type = Semin.CharacterType.Ned;
        Managers.UI.ClosePopupUI(BAEK.UIKEY.CharacterChoose);
    }
    IEnumerator CountDown()
    {
        float time = 15;
        while(time > 0)
        {
            countDownText.text = time.ToString();
            yield return new WaitForSeconds(1);
            time--;
        }
        Spawn();
    }
}
