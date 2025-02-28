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
    [SerializeField] Image groggy;
    [SerializeField] TextMeshProUGUI level;
    [SerializeField] GameObject myTeam;
    [SerializeField] GameObject otherTeam;
    [SerializeField] GameObject groggyObject;
    float maxHp;
    float maxDefence;
    float maxGroggy = 150;
    float decreaseTime = 0.1f;
    float hpValue, defenceValue, groggyValue;
    float targetHp, targetDefence, targetGroggy;
    Camera mainCamera;
    Coroutine decrease;
    bool stopHpUI = false;
    bool isOtherTeam = false;

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

    public bool IsShowUI()
    {
        return otherTeam.activeSelf;
    }

    public void ShowOtherTeamUI()
    {
        if (!isOtherTeam) return;
        otherTeam.SetActive(true);
    }

    public void HideOtherTeamUI()
	{
		if (!isOtherTeam) return;
		otherTeam.SetActive(false);
        groggyObject.SetActive(false);
    }

    public void ShowGroggy()
    {
        groggyObject.gameObject.SetActive(true);
    }

    public void HideGroggy()
	{
		groggyObject.gameObject.SetActive(false);
    }

    public void SetGroggyValue(float groggyValue)
	{
		if (stopHpUI) return;
		if (decrease != null)
			StopCoroutine(decrease);
		groggy.fillAmount = targetGroggy;
        this.groggyValue = groggyValue / maxGroggy;
        decrease = StartCoroutine(DecreaseGroggy());
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
        groggyValue = 1f;
        hp.fillAmount = 1f;
        defence.fillAmount = 1f;
        groggy.fillAmount = 1f;
		targetHp = 1f;
		targetDefence = 1f;
        targetGroggy = 1f;
		transform.GetComponent<Canvas>().worldCamera = Camera.main;
    }

    private void Update()
    {
        if (mainCamera != null)
            transform.GetComponent<RectTransform>().rotation = mainCamera.transform.rotation;
        else
		{
			transform.GetComponent<Canvas>().worldCamera = Camera.main;
			mainCamera = Camera.main;
        }
	}

    public void SetIsMyTeam(bool isMyTeam)
    {
        GameObject team;
        if (isMyTeam)
        {
            team = myTeam;
            team.SetActive(true);
            otherTeam.SetActive(false);
        }
        else
        {
            team = otherTeam;
            isOtherTeam = true;
            myTeam.SetActive(false);
            otherTeam.SetActive(true);
        }

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

    private IEnumerator DecreaseGroggy()
    {
        float startGroggy = groggy.fillAmount;
        float elapsedTime = 0f;
        targetGroggy = Mathf.Max(groggyValue, 0);
        while (elapsedTime < decreaseTime)
        {
			if (stopHpUI) yield break;
            groggyValue = Mathf.Lerp(startGroggy, targetGroggy, elapsedTime / decreaseTime);
            groggy.fillAmount = groggyValue;
            elapsedTime += Time.deltaTime;
            yield return null;
		}
        groggy.fillAmount = targetGroggy;
    }
}
