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
    public void Init(float hp)
    {
        maxHp = hp;
        hpBar.fillAmount = 1;
        nickName.text = Managers.UserData.userData.nickName;
    }
    public void UpdateUI(float hp)
    {
        hpBar.fillAmount = hp / maxHp;
    }
}
