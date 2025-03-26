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
    PlayerStateData playerStateData;
    public void Init(PlayerStateData playerStateData)
    {
        this.playerStateData = playerStateData;
        defenceBar.fillAmount = 1;
        hpBar.fillAmount = 1;
        nickName.text = playerStateData.nickname.ToString();
    }
    public void UpdateUI()
    {
        if (playerStateData == null) return;
        dieIcon.SetActive(!playerStateData.playerStatus.isLive);
        hpBar.fillAmount = playerStateData.playerStatus.hp / playerStateData.playerStatus.maxHp;
        defenceBar.fillAmount = playerStateData.playerStatus.defence / playerStateData.playerStatus.maxDefence;
    }
}
