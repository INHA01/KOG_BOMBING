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
    SceneLoadManager _sceneLoad = new SceneLoadManager();
    SoundManager _sound;
    public static UserDataManager UserData { get { return Instance._userData; } }
    
    public static PlayerPointManager PointData { get {return Instance._pointData; } }
    public static RoundInfoManager RoundData { get { return Instance._roundData; } }
    public static SceneLoadManager SceneLoad { get { return Instance._sceneLoad; } }
    public static SoundManager Sound { get { return Instance._sound; } }
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

                //DontDestroyOnLoad(go);
                s_instance = go.GetComponent<Managers>();
            }
            return s_instance;
        } 
    }
    private void Start()
    {
        Init();
    }
    void Init()
    {
        _sceneLoad.Init();
        _sound = gameObject.GetComponentInChildren<SoundManager>();
        _sound.Init();
        s_instance = GetComponent<Managers>();
    }
}
