using System;
using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class BombNotify : MonoBehaviour
{
    enum BombUI
    {
        Time,
        GuideText,
        BombSet,
        BombDefuse,
        CanInteractBomb,
        Max
    }
    enum TextType
    {
        TimeCount,
        Guide,
        Max
    }
    [SerializeField] GameObject[] bombUIs = new GameObject[(int)BombUI.Max];
    [SerializeField] TextMeshProUGUI[] texts = new TextMeshProUGUI[(int)TextType.Max];

    Coroutine bombSetCoroutine;
    ETeam teamType;
    public void NotifyGuide(bool isNotify , ETeam team)
    {
        bombUIs[(int)BombUI.GuideText].SetActive(isNotify);
        if (!isNotify) return;
        teamType = team;
        if (teamType == ETeam.REDTEAM)
        {
            texts[(int)TextType.Guide].color = Color.red;
            texts[(int)TextType.Guide].text = "폭탄 설치 구역에서 폭탄을 설치하세요!!\n\n<color=yellow>공격버튼을 누르는 동안 설치가 진행됩니다.</color>";
        }
        else
        {
            texts[(int)TextType.Guide].color = Color.blue;
            texts[(int)TextType.Guide].text = "폭탄을 찾아 해체하세요!!\n\n<color=yellow>공격버튼을 누르는 동안 해체가 진행됩니다.</color>";
        }
    }
    public void ActiveCanInteractBomb(bool canDefuse)
    {
        bombUIs[(int)BombUI.CanInteractBomb].SetActive(canDefuse);
    }
    public void SetTimeCount(float time)
    {
        texts[(int)TextType.TimeCount].text = string.Format("{0:00}:{1:00}", (int)time, (int)((time - (int)time) * 100));
    }
    public void NotifyBombSet()
    {
        SoundManager.Instance.PlayUISound(EUiSoundType.BOMBLAUNCHED);
        bombUIs[(int)BombUI.Time].SetActive(true);
        bombUIs[(int)BombUI.BombSet].SetActive(true);
        bombUIs[(int)BombUI.BombDefuse].SetActive(false);
        if(bombSetCoroutine != null)
            StopCoroutine(bombSetCoroutine);
        bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(true));
    }
    public void NotifyBombDefuse()
    {
        bombUIs[(int)BombUI.Time].SetActive(false);
        bombUIs[(int)BombUI.BombSet].SetActive(false);
        bombUIs[(int)BombUI.BombDefuse].SetActive(true);

        if(bombSetCoroutine != null)
            StopCoroutine(bombSetCoroutine);
        bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(false));
    }

    IEnumerator NotifyBombSetCoroutine(bool isSet)
    {
        GameObject bomb = isSet ? bombUIs[(int)BombUI.BombSet] : bombUIs[(int)BombUI.BombDefuse];
        Image bombImage = bomb.GetComponent<Image>();
        Color color = bombImage.color;
        float time = 0;
        float addValue = -0.01f;
        while (time <= 10)
        {
            yield return null;
            color.a += addValue;
            if(color.a <= 0 || color.a >= 1)
            {
                addValue *= -1;
            }
            bombImage.color = color;
            time += Time.deltaTime;
        }
        bomb.SetActive(false);
    }
    public void ActiveFalseAll()
    {
        for (int i = 0; i < bombUIs.Length; i++)
            bombUIs[i].SetActive(false);
    }
}
