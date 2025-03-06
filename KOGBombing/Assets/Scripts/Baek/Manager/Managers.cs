using System.Collections;
using System.Collections.Generic;
using System.Resources;
using UnityEngine;
using Orpul1;
public class Managers : MonoBehaviour
{
    static Managers s_instance;

    UserDataManager _userData = new UserDataManager();
    PlayerPointManager _pointData = new PlayerPointManager();
    RoundInfoManager _roundData = new RoundInfoManager();
    public static UserDataManager UserData { get { return Instance._userData; } }
    
    public static PlayerPointManager PointData { get {return Instance._pointData; } }
    public static RoundInfoManager RoundData { get { return Instance._roundData; } }
    static Managers Instance 
    { 
        get 
        {
            if (s_instance == null)
            {
                GameObject go = GameObject.Find("@MyManagers");
                if (go == null)
                {
                    // Hierarchi 코드로 오브젝트 만들고 스크립트 넣음
                    go = new GameObject { name = "@MyManagers" };
                    go.AddComponent<Managers>();
                }

                DontDestroyOnLoad(go);
                s_instance = go.GetComponent<Managers>();
            }
            return s_instance;
        } 
    }

    void Start()
    {
        // 초기화 작업을 여기에 추가
    }

}
