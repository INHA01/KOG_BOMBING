using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Firebase.Auth;
using TMPro;
using System;
using Firebase.Database;
using System.Runtime.InteropServices;
using UnityEditor;
using System.Threading.Tasks;

public class FirebaseAughManager
{
    public FirebaseAuth auth; // 로그인, 회원가입, 비밀번호 재설정 등의 기능을 제공하는 클래스
    private FirebaseUser user; // 인증된 사용자 정보를 저장하는 클래스
    private DatabaseReference databaseReference; // Firebase Database 참조
    public string UserId => user.UserId; // 사용자 고유 ID

    public bool isLogin = false;
    string currentDeviceId;

    public void Init()
    {
        Application.wantsToQuit += ApplicationQuit;
        currentDeviceId = SystemInfo.deviceUniqueIdentifier;
        Debug.Log("deviceID : " + currentDeviceId);
        auth = FirebaseAuth.DefaultInstance; // FirebaseAuth 클래스의 인스턴스를 가져
        databaseReference = FirebaseDatabase.DefaultInstance.RootReference; // Firebase Database의 루트 참조를 가져옴
        //// 임시 : 이미 로그인 되어있으면 로그아웃
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
                isLogin = false;
            }
            user = auth.CurrentUser;
            if (signedIn)
            {
                Debug.Log("로그인 : " + user.DisplayName + " (" + user.Email + ")");
                isLogin = true;
            }
        }
    }

    public void Create(string email, string password , string nickName)
    {
        auth.CreateUserWithEmailAndPasswordAsync(email, password).ContinueWith(task =>
        {
            if (task.IsCanceled)
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
            Managers.UserData.Init(auth);
            Managers.UserData.SettingNickName(nickName);
            SetDeviceStatus(newUser.UserId);
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
                Debug.LogError("로그인 실패.");
                return;
            }

            // 로그인 성공
            AuthResult result = task.Result;
            FirebaseUser newUser = result.User;
            Debug.LogFormat("로그인 성공 : {0} ({1})", newUser.DisplayName, newUser.Email);
            CheckDeviceStatus();
            Managers.UserData.Init(auth);
        });
    }

    public void Logout(bool isCheck = false)
    {
        if (auth.CurrentUser != null)
        {
            if (!isCheck)
            {
                // 로그아웃 시 기기 상태 삭제
                databaseReference.Child("users").Child(auth.CurrentUser.UserId).Child("deviceID").SetValueAsync("").ContinueWith(task =>
                {
                    if (task.IsCompleted)
                        Debug.Log("기기 ID 삭제 완료");
                    else
                        Debug.LogError("기기 ID 삭제 실패");
                });
            }
        }
        auth.SignOut(); // 로그아웃
    }

    private bool ApplicationQuit()
    {
        Logout();
        return true;
    }

    private void CheckDeviceStatus()
    {
        if (auth.CurrentUser == null)
        {
            Debug.LogError("사용자 정보 없음");
            return;
        }
        // 데이터베이스에서 기기 ID 확인
        databaseReference.Child("users").Child(user.UserId).Child("deviceID").GetValueAsync().ContinueWith(task =>
        {
            if (task.IsCompleted)
            {
                DataSnapshot snapshot = task.Result;
                if (snapshot.Exists && snapshot.Value.ToString() != "")
                {
                    if (snapshot.Value.ToString() == currentDeviceId)
                    {
                        Debug.Log("접속 중 기기 일치 다시 로그인 시도하기");
                        Logout(false);
                    }
                    else
                    {
                        Debug.Log("중복 로그인 감지! 로그아웃 처리 중...");
                        Logout(true); // 중복 로그인 시 로그아웃
                    }
                }
                else
                {
                    Debug.Log("접속 중 기기 없음");
                    SetDeviceStatus(user.UserId); // 기기 상태 설정
                }
            }
        });
    }


    private void SetDeviceStatus(string userId)
    {
        // 현재 기기 ID 저장
        databaseReference.Child("users").Child(userId).Child("deviceID").SetValueAsync(currentDeviceId).ContinueWith(task =>
        {
            if (task.IsCompleted)
                Debug.Log("기기 ID 저장 완료");
            else
                Debug.LogError("기기 ID 저장 실패");
        });
    }
}
