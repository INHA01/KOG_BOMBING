using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LobbyModeSelect : MonoBehaviour
{
    [SerializeField] GameObject matchSelect;
    public int mode = 0;
    public void TurnBackScreen()
    {
        matchSelect.SetActive(false);
        Managers.UI.ClosePopupUI(this.gameObject.name);
    }
    public void OnBombModeClick()
    { 
        matchSelect.SetActive(true);
    }
    public void OnRandomMatchSelect()
    {
        mode = 0;
    }
    public void OnCustomMatchSelect()
    {
        mode = 1;
    }
}
