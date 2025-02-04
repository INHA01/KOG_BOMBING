using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class HpBar : MonoBehaviour
{
    [SerializeField] Image hp;
    [SerializeField] Image defence;
    [SerializeField] TextMeshProUGUI level;
    [SerializeField] GameObject myTeam;
    [SerializeField] GameObject otherTeam;
    float maxHp;
    float hpValue;
    float maxDefenece;
    float defenceValue;
    float decreaseTime = 0.5f;
    Camera mainCamera;
    Coroutine decrease;

    public void SetDefenceValue(float defenceValue)
    {
		this.defenceValue = defenceValue;
        defence.fillAmount = this.defenceValue / maxDefenece;
    }

    public void SetHpValue(float hpValue)
    {
        if (decrease != null)
            StopCoroutine(decrease);
        this.hpValue = hpValue;
        decrease = StartCoroutine(DecreaseHP());

    }

    public void Init(Camera camera, float maxHp)
    {
        mainCamera = camera;
        this.maxHp = maxHp;
        transform.GetComponent<Canvas>().worldCamera = camera;
    }

    private void Update()
    {
        transform.rotation = mainCamera.transform.rotation;
    }

    public void SetTeam(bool isOtherTeam)
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
        float targetHP = Mathf.Max(hpValue / maxHp, 0);
        float startHP = hp.fillAmount;
        float elapsedTime = 0f; 

        while (elapsedTime < decreaseTime)
        {
            hpValue = Mathf.Lerp(startHP, targetHP, elapsedTime / decreaseTime);
            hp.fillAmount = hpValue;
            elapsedTime += Time.deltaTime;
            yield return null; 
        }

        hp.fillAmount = targetHP;
        decrease = null;
    }
}
