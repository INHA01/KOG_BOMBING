using Firebase.Auth;
using Firebase.Database;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserData
{
    public string email;
    public string nickName;
    public int kill;
    public int death;
    public int win;
    public int lose;
    public float winningRate;

    public UserData(string email)
    {
        this.email = email;
        nickName = "User";
        kill = 0;
        death = 0;
        win = 0;
        lose = 0;
        winningRate = 0;
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

    public void SaveUserData(string username)
    {
        if (auth.CurrentUser != null)
        {
            string userId = auth.CurrentUser.UserId;
            //UserData userData = new UserData(username);

            string json = JsonUtility.ToJson(userData);
            databaseReference.Child("users").Child(userId).SetRawJsonValueAsync(json).ContinueWith(task =>
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
            databaseReference.Child("users").Child(userId).GetValueAsync().ContinueWith(task =>
            {
                if (task.IsCompleted)
                {
                    DataSnapshot snapshot = task.Result;
                    if (snapshot.Exists)
                    {
                        //UserData userData = JsonUtility.FromJson<UserData>(snapshot.GetRawJsonValue());
                        Debug.Log("Username: " + userData.nickName + ", Email: " + userData.email);
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
            databaseReference.Child("users").Child(userId).GetValueAsync().ContinueWith(task =>
            {
                if (task.IsCompleted)
                {
                    DataSnapshot snapshot = task.Result;
                    if (snapshot.Exists)
                    {
                        userData = JsonUtility.FromJson<UserData>(snapshot.GetRawJsonValue());
                        Debug.Log("Username: " + userData.nickName + ", Email: " + userData.email);
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
        return userData;
    }
}
