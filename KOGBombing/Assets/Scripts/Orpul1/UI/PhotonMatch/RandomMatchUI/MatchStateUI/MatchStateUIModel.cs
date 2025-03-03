using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchStateUIModel : MonoBehaviour
{
    Action updateUI;
    private float countValue = 0;
    public float CountValue { get { return countValue; } }
    [SerializeField]
    float finishTime;
    [SerializeField]
    float maxTimeInterval = 5f;
    bool isStopCoroutine;
    bool isRunningCoroutine;

    public void Initialize(Action UpdateUI)
    {
        this.updateUI = UpdateUI;
    }
    public void ProcessRoundAni()
    {
        isStopCoroutine = false;
        StartCoroutine(CoStartCount());
    }
    public void AbortRoundAni()
    {
        isRunningCoroutine = false;
        isStopCoroutine = true;
    }
    IEnumerator CoStartCount()
    {
        if (isRunningCoroutine) yield break;
        isRunningCoroutine = true;
        float elapsedTime = 0;
        while (true)
        {
            if (isStopCoroutine) yield break;

            float time = elapsedTime / finishTime;
            countValue = 1 - Mathf.Exp(-maxTimeInterval * time);
            elapsedTime += Time.deltaTime;

            updateUI();
            if (countValue >= 0.99f)
            {
                elapsedTime = 0;
                countValue = 0;
            }
            yield return null;
        }
    }
}
