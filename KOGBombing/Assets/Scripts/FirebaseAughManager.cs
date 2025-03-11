using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase.Auth;
using TMPro;
using System;

public class FirebaseAughManager
{
    private static FirebaseAughManager instance = null;

    public static FirebaseAughManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new FirebaseAughManager();
            }
            return instance;
        }
    }

    public FirebaseAuth auth; // 로그인, 회원가입, 비밀번호 재설정 등의 기능을 제공하는 클래스
    private FirebaseUser user; // 인증된 사용자 정보를 저장하는 클래스

    public string UserId => user.UserId; // 사용자 고유 ID

    public Action<bool> LoginState;

    // real-time database
    public UserDataManager userDataManager = new UserDataManager();
    // 
    public void Init()
    {
        auth = FirebaseAuth.DefaultInstance; // FirebaseAuth 클래스의 인스턴스를 가져
        // 임시 : 이미 로그인 되어있으면 로그아웃
        if (auth.CurrentUser != null)
            Logout();
        auth.StateChanged += AuthStateChanged; // 인증 상태가 변경될 때 호출되는 이벤트
    }
    void AuthStateChanged(object sender, System.EventArgs eventArgs)
    {
        if (auth.CurrentUser != user)
        {
            bool signedIn = ((user != auth.CurrentUser) && (auth.CurrentUser != null));
            if (!signedIn && user != null)
            {
                Debug.Log("로그아웃");
                LoginState?.Invoke(false);
            }
            user = auth.CurrentUser;
            if (signedIn)
            {
                Debug.Log("로그인 : " + user.DisplayName + " (" + user.Email + ")");
                LoginState?.Invoke(true);
            }
        }
    }

    public void Create(string email , string password)
    {
        auth.CreateUserWithEmailAndPasswordAsync(email, password).ContinueWith(task => 
        {
            if(task.IsCanceled)
            {
                Debug.LogError("회원가입 취소.");
                return;
            }
            if (task.IsFaulted)
            {
                // 회원가입 실패 , 이유 : 이메일 비정상 , 비밀번호 간단 , 이미 가입됨 등...
                Debug.LogError("회원가입 실패.");
                return;
            }

            // 회원가입 성공
            AuthResult result = task.Result;
            FirebaseUser newUser = result.User;
            Debug.LogFormat("회원가입 성공 : {0} ({1})", newUser.DisplayName, newUser.Email);
        });
    }

    public void Login(string email, string password)
    {
        auth.SignInWithEmailAndPasswordAsync(email, password).ContinueWith(task =>
        {
            if (task.IsCanceled)
            {
                Debug.LogError("로그인 취소.");
                return;
            }
            if (task.IsFaulted)
            {
                // 회원가입 실패 , 이유 : 이메일 비정상 , 비밀번호 간단 , 이미 가입됨 등...
                Debug.LogError("로그인 실패.");
                return;
            }

            // 로그인 성공
            AuthResult result = task.Result;
            FirebaseUser newUser = result.User;
            Debug.LogFormat("로그인 성공 : {0} ({1})", newUser.DisplayName, newUser.Email);
            userDataManager.Init(auth);
        });
    }

    public void Logout()
    {
        auth.SignOut(); // 로그아웃
        Debug.Log("로그아웃");
    }

    public void SendPasswordResetEmail(string email, System.Action<bool> callback)
    {
        auth.SendPasswordResetEmailAsync(email).ContinueWith(task =>
        {
            if (task.IsFaulted)
            {
                Debug.LogError("비밀번호 재설정 이메일 발송 실패: " + task.Exception);
                callback(false);
            }
            else
            {
                callback(true);
            }
        });
    }
}
