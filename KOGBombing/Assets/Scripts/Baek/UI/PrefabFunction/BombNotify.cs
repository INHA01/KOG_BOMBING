using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class BombNotify : MonoBehaviour
{
    [SerializeField] GameObject bombUI;
    [SerializeField] TextMeshProUGUI timeCount;
    [SerializeField] GameObject bombSet;
    [SerializeField] GameObject bombDefuse;

    Coroutine bombSetCoroutine;
    public void SetTimeCount(float time)
    {
        timeCount.text = string.Format("{0:00}:{1:00}", (int)time, (int)((time - (int)time) * 100));
    }
    public void NotifyBombSet()
    {
        bombUI.SetActive(true);
        bombSet.SetActive(true);
        bombDefuse.SetActive(false);
        if(bombSetCoroutine != null)
            StopCoroutine(bombSetCoroutine);
        bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(true));
    }
    public void NotifyBombDefuse()
    {
        bombUI.SetActive(false);
        bombSet.SetActive(false);
        bombDefuse.SetActive(true);
        if(bombSetCoroutine != null)
            StopCoroutine(bombSetCoroutine);
        bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(false));
    }

    IEnumerator NotifyBombSetCoroutine(bool isSet)
    {
        GameObject bomb = isSet ? bombSet : bombDefuse;
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
        bombUI.SetActive(false);
        bomb.SetActive(false);

    }
}
