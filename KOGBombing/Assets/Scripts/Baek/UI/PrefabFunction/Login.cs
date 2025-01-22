using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Login : MonoBehaviour
{
    [SerializeField] GameObject _login;
    [SerializeField] GameObject _serverSelect;
    public void OnLoginClick()
    {
        _login.SetActive(false);
        _serverSelect.SetActive(true);
    }
    public void OnStartClick()
    { 
        LoadingSceneManager.LoadScene("AttackTest");
    }

}
