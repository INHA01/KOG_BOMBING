using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using static UnityEngine.GraphicsBuffer;

public class HpBar : MonoBehaviour
{
    [SerializeField] Image hp;
    [SerializeField] Image defence;
    [SerializeField] TextMeshProUGUI level;
    [SerializeField] GameObject myTeam;
    [SerializeField] GameObject otherTeam;
    float maxHp;
    float hpValue;
    float maxDefence;
    float defenceValue;
    float decreaseTime = 0.5f;
    float damageValue;
    float targetHp, targetDefence;
    Camera mainCamera;
    Coroutine decrease;
    bool stopHpUI = false;
    public void SetHpValue(float hpValue, float defenceValue)
    {
        if (stopHpUI) return;
        if (decrease != null)
            StopCoroutine(decrease);
        hp.fillAmount = targetHp;
        defence.fillAmount = targetDefence;
        this.hpValue = hpValue / maxHp;
        this.defenceValue = defenceValue / maxDefence;
        decrease = StartCoroutine(DecreaseHP());
    }

    public void SetStopHpUI(bool value)
    {
        stopHpUI = value;
    }
    public void InitializeValues()
    {
        if (decrease != null)
            StopCoroutine(decrease);
		hp.fillAmount = 1f;
		defence.fillAmount = 1f;
        hpValue = 1f;
        defenceValue = 1f;
		targetHp = 1f;
		targetDefence = 1f;
	}

    public void Init(float maxHp, float maxDefence)
    {
        mainCamera = Camera.main;
        this.maxHp = maxHp;
        this.maxDefence = maxDefence;
        hpValue = 1f;
        defenceValue = 1f;
        hp.fillAmount = 1f;
        defence.fillAmount = 1f;
		targetHp = 1f;
		targetDefence = 1f;
		transform.GetComponent<Canvas>().worldCamera = GetComponent<Camera>();
    }

    private void Update()
    {
        if (mainCamera != null)
            transform.rotation = mainCamera.transform.rotation;
    }

    public void SetIsMyTeam(bool isOtherTeam)
    {
        GameObject team;
        if (isOtherTeam)
            team = otherTeam;
        else team = myTeam;

        team.SetActive(true);
        Debug.Log(team.transform.GetChild(0).gameObject);  
        level = team.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
        hp = team.transform.GetChild(2).GetComponent<Image>();
        defence = team.transform.GetChild(3).GetComponent<Image>();
    }

    private IEnumerator DecreaseHP()
    {
        float startHP = hp.fillAmount;
        float startDefence = defence.fillAmount;
        float elapsedTime = 0f;
		targetHp = Mathf.Max(hpValue, 0);
        targetDefence = Mathf.Max(defenceValue, 0);

		while (elapsedTime < decreaseTime)
        {
            if (stopHpUI) yield break;
            hpValue = Mathf.Lerp(startHP, targetHp, elapsedTime / decreaseTime);
            defenceValue = Mathf.Lerp(startDefence, targetDefence, elapsedTime / decreaseTime);
            hp.fillAmount = hpValue;
            defence.fillAmount = defenceValue;
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        hp.fillAmount = targetHp;
        defence.fillAmount = targetDefence; 
        decrease = null;
    }
}
