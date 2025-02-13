using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TeamProfile : MonoBehaviour
{
    [SerializeField] GameObject dieIcon;
    [SerializeField] TextMeshProUGUI nickName;
    [SerializeField] Image hpBar;
    [SerializeField] Image defenceBar;
    PlayerBlackBoard blackBoard;
    public void Init(PlayerBlackBoard blackBoard)
    {
        this.blackBoard = blackBoard;
        defenceBar.fillAmount = 1;
        hpBar.fillAmount = 1;
        nickName.text = blackBoard.nickname;
    }
    public void UpdateUI()
    {
        dieIcon.SetActive(!blackBoard.playerStatus.isLive);
        hpBar.fillAmount = blackBoard.playerStatus.hp / blackBoard.playerStatus.maxHp;
        defenceBar.fillAmount = blackBoard.playerStatus.defence / blackBoard.playerStatus.maxDefence;
    }
}
