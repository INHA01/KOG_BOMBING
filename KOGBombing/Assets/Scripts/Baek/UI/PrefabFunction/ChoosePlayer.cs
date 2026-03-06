using Orpul1;
using Photon.Pun;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using BAEK;

public class ChoosePlayer : MonoBehaviour
{
    [SerializeField] protected Transform teamIconBack;
    [SerializeField] TextMeshProUGUI characterName;
    [SerializeField] TextMeshProUGUI teamType;
    [SerializeField] TextMeshProUGUI countDownText;
    public Semin.CharacterType type;

    [SerializeField] Subject subject;
    public Subject Subject => subject;
    [SerializeField] SubjectParam<int> subjectParam;
    public SubjectParam<int> SubjectParam => subjectParam;

    public void SetCharacterName(int index)
    {
        type = (Semin.CharacterType)index;
        characterName.text = type.ToString();
        subjectParam.Notify(index);
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

        SetCharacterName((int)type);
        SetIcon(true);
        StartCoroutine(CountDown());
    }
    public virtual void SetIcon(bool isMine)
    {
        //GameObject go = null;
        //go = Managers.Resource.Instantiate(FactoryType.SupportUI, (int)SupportUI.ChooseIconBack, teamIconBack);
        //if (isMine)
        //{
        //    go.GetComponent<ChooseAvatarIcon>().SetSubject(this , true);
        //}
    }
    
    public void Spawn()
    {
        //EventBusSystem.Publish();
        subject.Notify();
        subject.ClearObservers();

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
