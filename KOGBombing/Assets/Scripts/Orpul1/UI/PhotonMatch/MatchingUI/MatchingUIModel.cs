using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatchingUIModel : MonoBehaviour
{
    Action updateUI;
    private float countValue = 0;
    public float CountValue { get { return countValue; } }
    [SerializeField]
    float finishTime;
    [SerializeField]
    float maxTimeInterval = 5f;

    void Start()
    {
        updateUI = GetComponent<MatchingUIPresenter>().UpdateUI;
    }
    public void RunCountTime()
    {
        StartCoroutine(CoStartCount());
    }
    IEnumerator CoStartCount()
    {
        float elapsedTime = 0;
        while (true)
        {
            float time = elapsedTime / finishTime;
            countValue = 1 - Mathf.Exp(-maxTimeInterval * time);
            elapsedTime += Time.deltaTime;

            updateUI();
            if (countValue >= 0.99f)
            {
                countValue = 0;
                break;
            }
            yield return null;
        }
    }
}
