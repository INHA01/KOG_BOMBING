using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserData
{
    public string nickName;
    public int kill;
    public int death;
    public int win;
    public int lose;
    public float winningRate;

    public UserData()
    {
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

    public UserDataManager()
    { 
        userData = new UserData();
    }
}
