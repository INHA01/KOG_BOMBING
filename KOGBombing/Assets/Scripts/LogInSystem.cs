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
        FirebaseAughManager.Instance.LoginState += AuthStateChanged;
        FirebaseAughManager.Instance.Init();
    }
    void AuthStateChanged(bool state)
    {
        outputText.text = state ? "로그인 성공" : "로그인 실패";
        outputText.text += FirebaseAughManager.Instance.UserId;
    }
    public void Create()
    {
        FirebaseAughManager.Instance.Create(email.text, password.text);
    }
    public void LogIn()
    {
        FirebaseAughManager.Instance.Login(email.text, password.text);

    }
    public void LogOut()
    {
        FirebaseAughManager.Instance.Logout();
    }
    public void DataInputTest()
    {
        FirebaseAughManager.Instance.userDataManager.SaveUserData(email.text);
    }
    public void DataOutputTest()
    {
        FirebaseAughManager.Instance.userDataManager.LoadUserData();
    }
    public void ResetPassword()
    {
        if (string.IsNullOrEmpty(email.text))
        {
            outputText.text = "이메일 주소를 입력하세요.";
            return;
        }

        FirebaseAughManager.Instance.SendPasswordResetEmail(email.text, (success) =>
        {
            outputText.text = success ? "비밀번호 재설정 이메일이 발송되었습니다." : "비밀번호 재설정 이메일 발송 실패.";
        });
    }
}
