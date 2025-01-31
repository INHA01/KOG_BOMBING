using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HpBar : MonoBehaviour
{
    [SerializeField] Image hp;
    [SerializeField] Image defence;
    float maxHp;
    float hpValue;
    float maxDefenece;
    float defenceValue;

    public void SetDefenceValue(float defenceValue)
    {
		this.defenceValue = defenceValue;
        defence.fillAmount = this.defenceValue / maxDefenece;
    }

    public void SetHpValue(float hpValue)
    {
        this.hpValue = hpValue;
        hp.fillAmount = this.hpValue / maxHp;
    }
}
