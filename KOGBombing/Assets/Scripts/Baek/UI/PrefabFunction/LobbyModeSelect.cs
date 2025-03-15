using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LobbyModeSelect : UIPopup
{
    [SerializeField] GameObject matchSelect;
    [SerializeField] Animator animator;
    public int mode = 0;
    private void OnEnable()
    {
        animator.SetBool("IsOut", false);
    }
    public void TurnBackScreen()
    {
        animator.SetBool("IsOut", true);
        matchSelect.SetActive(false);
        StartCoroutine(FadeOut());

    }
    IEnumerator FadeOut()
    {
        yield return new WaitForSeconds(0.8f);
        Managers.UI.ClosePopupUI(this.gameObject.name);
    }
    public void OnBombModeClick()
    { 
        matchSelect.SetActive(true);
    }
    public void OnRandomMatchSelect()
    {
        mode = 0;
        TurnBackScreen();
    }
    public void OnCustomMatchSelect()
    {
        mode = 1;
        TurnBackScreen();
    }
}
