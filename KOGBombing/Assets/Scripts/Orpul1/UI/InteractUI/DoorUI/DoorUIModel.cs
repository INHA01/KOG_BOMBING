using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorUIModel : MonoBehaviour
{
    [SerializeField] float deactiveTime;
    WaitForSeconds delayTime;
    Action<EDoorState,bool> updateUI;
    private void Start()
    {
        delayTime = new WaitForSeconds(deactiveTime);
    }
    public void SetUpdateUI(Action<EDoorState,bool> updateUI)
    {
        this.updateUI = updateUI;
    }
    public void AlertDoorOpen()
    {
        StartCoroutine(CoDeactiveDelay());
        Managers.Sound.PlayUISound(EUiSoundType.OPENDOOR);
        updateUI(EDoorState.OPEN,true);
    }
    IEnumerator CoDeactiveDelay()
    {
        yield return delayTime;
        updateUI(EDoorState.OPEN, false);
    }
}
