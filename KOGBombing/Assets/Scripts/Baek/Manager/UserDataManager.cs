using Firebase.Auth;
using Firebase.Database;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserData
{
    public string userId;
    public string nickName;
    public int kill;
    public int death;
    public int win;
    public int lose;
    public float winningRate;
    public int level;
    public float exp;

    public UserData(string userId)
    {
        this.userId = userId;
        nickName = "User";
        kill = 0;
        death = 0;
        win = 0;
        lose = 0;
        winningRate = 0;
        level = 1;
        exp = 0;
    }
}
public class UserDataManager
{
    public UserData userData;

    private FirebaseAuth auth;
    private DatabaseReference databaseReference;

    public void Init(FirebaseAuth auth)
    {
        this.auth = auth;
        databaseReference = FirebaseDatabase.DefaultInstance.RootReference;
        userData = GetUserData();
    }

    public void SaveUserData()
    {
        if (auth.CurrentUser != null)
        {
            string userId = auth.CurrentUser.UserId;
            string json = JsonUtility.ToJson(userData);
            databaseReference.Child("users").Child(userId).Child("Data").SetRawJsonValueAsync(json).ContinueWith(task =>
            {
                if (task.IsCompleted)
                {
                    Debug.Log("User data saved successfully!");
                }
                else
                {
                    Debug.LogError("Failed to save user data: " + task.Exception);
                }
            });
        }
        else
        {
            Debug.LogError("No user is signed in.");
        }
    }
    public void LoadUserData()
    {
        if (auth.CurrentUser != null)
        {
            string userId = auth.CurrentUser.UserId;
            databaseReference.Child("users").Child(userId).Child("Data").GetValueAsync().ContinueWith(task =>
            {
                if (task.IsCompleted)
                {
                    DataSnapshot snapshot = task.Result;
                    if (snapshot.Exists)
                    {
                        userData = JsonUtility.FromJson<UserData>(snapshot.GetRawJsonValue());
                        Debug.Log("Username: " + userData.nickName + ", ID: " + userData.userId);
                    }
                    else
                    {
                        Debug.Log("No user data found.");
                    }
                }
                else
                {
                    Debug.LogError("Failed to load user data: " + task.Exception);
                }
            });
        }
        else
        {
            Debug.LogError("No user is signed in.");
        }
    }
    public UserData GetUserData()
    {
        if (auth.CurrentUser != null)
        {
            string userId = auth.CurrentUser.UserId;
            databaseReference.Child("users").Child(userId).Child("Data").GetValueAsync().ContinueWith(task =>
            {
                if (task.IsCompleted)
                {
                    DataSnapshot snapshot = task.Result;
                    // 해당 유저의 데이터가 존재하면
                    if (snapshot.Exists)
                    {
                        userData = JsonUtility.FromJson<UserData>(snapshot.GetRawJsonValue());
                        Debug.Log("Username: " + userData.nickName + ", ID: " + userData.userId);
                    }
                    // 해당 유저의 데이터가 존재하지 않으면
                    else
                    {
                        userData = new UserData(auth.CurrentUser.UserId);
                        SaveUserData();
                        Debug.Log("No user data found.");
                    }
                }
            });

        }
        return userData;
    }

    public void SettingNickName(string nickName)
    {
        // 다른 유저가 사용중인 닉네임이 아니라면
        databaseReference.Child("users").OrderByChild("Data/nickName").EqualTo(nickName).GetValueAsync().ContinueWith(task =>
        {
            if (task.IsCompleted)
            {
                DataSnapshot snapshot = task.Result;
                // 닉네임이 사용 중이지 않은 경우
                if (!snapshot.Exists)
                {
                    userData.nickName = nickName; // 닉네임 설정
                    SaveUserData(); // 사용자 데이터 저장
                }
                else
                {
                    Debug.Log("The nickname is already in use."); // 닉네임 사용 중 경고
                }
            }
        });
    }
}
