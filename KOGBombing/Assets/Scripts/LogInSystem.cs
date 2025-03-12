using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class LogInSystem : MonoBehaviour
{
    public TextMeshProUGUI email;
    public TextMeshProUGUI password;

    public TextMeshProUGUI outputText;
    void Start()
    {
        //Managers.FirebaseAuth.LoginState += AuthStateChanged;
        Managers.FirebaseAuth.Init();
    }
    void AuthStateChanged(bool state)
    {
        outputText.text = state ? "로그인 성공" : "로그인 실패";
        outputText.text += Managers.FirebaseAuth.UserId;
    }
    public void Create()
    {
        Managers.FirebaseAuth.Create(email.text, password.text);
    }
    public void LogIn()
    {
        Managers.FirebaseAuth.Login(email.text, password.text);

    }
    public void LogOut()
    {
        Managers.FirebaseAuth.Logout();
    }
    public void DataInputTest()
    {
        Managers.UserData.SaveUserData();
    }
    public void DataOutputTest()
    {
        Managers.UserData.LoadUserData();
    }
}
