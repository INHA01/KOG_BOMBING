using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TeamProfile : MonoBehaviour
{
    [SerializeField] Sprite[] profileSprites;
    [SerializeField] TextMeshProUGUI nickName;
    [SerializeField] GameObject dieIcon;
    [SerializeField] Image profileImage;
    [SerializeField] Image hpBar;
    [SerializeField] Image defenceBar;
    PlayerBlackBoard blackBoard;
    public void Init(PlayerBlackBoard blackBoard)
    {
        this.blackBoard = blackBoard;
        profileImage.sprite = profileSprites[(int)blackBoard.characterType];
        defenceBar.fillAmount = 1;
        hpBar.fillAmount = 1;
        nickName.text = blackBoard.nickname;
    }
    public void UpdateUI()
    {
        if (blackBoard == null) return;
        dieIcon.SetActive(!blackBoard.playerStatus.isLive);
        hpBar.fillAmount = blackBoard.playerStatus.hp / blackBoard.playerStatus.maxHp;
        defenceBar.fillAmount = blackBoard.playerStatus.defence / blackBoard.playerStatus.maxDefence;
    }
}
