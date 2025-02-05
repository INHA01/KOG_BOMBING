using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TeamProfile : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI nickName;
    public Image hpBar;
    public Image defenceBar;
    float maxHp;
    float maxDefence;
    public void Init(PlayerBlackBoard blackBoard)
    {
        maxHp = blackBoard.maxHp;
        maxDefence = blackBoard.maxDefence;
        defenceBar.fillAmount = 1;
        hpBar.fillAmount = 1;
        nickName.text = blackBoard.nickname;
    }
    public void UpdateUI(float hp, float defence)
    {
        hpBar.fillAmount = hp / maxHp;
        defenceBar.fillAmount = defence / maxDefence;
    }

}
