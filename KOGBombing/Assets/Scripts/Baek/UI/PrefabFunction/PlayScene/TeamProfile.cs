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
    float maxHp;
    [SerializeField]
    PlayerBlackBoard blackBoard;
    public void Init(float hp, PlayerBlackBoard blackBoard)
    {
        this.blackBoard = blackBoard;
        maxHp = hp;
        hpBar.fillAmount = 1;
        nickName.text = blackBoard.nickname;
    }
    public void UpdateUI(float hp)
    {
        hpBar.fillAmount = hp / maxHp;
    }

}
