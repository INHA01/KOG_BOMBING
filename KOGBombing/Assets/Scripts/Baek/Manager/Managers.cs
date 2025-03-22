using System.Collections;
using System.Collections.Generic;
using System.Resources;
using UnityEngine;
using Orpul1;
using BAEK;
public class Managers : MonoBehaviour , InitClass
{
    static Managers s_instance;
    FirebaseAughManager _firebaseAuth = new FirebaseAughManager();
    UserDataManager _userData = new UserDataManager();
    PlayerPointManager _pointData = new PlayerPointManager();
    RoundInfoManager _roundData = new RoundInfoManager();
    SceneLoadManager _sceneLoad = new SceneLoadManager();
    SoundManager _sound;

    UIManager _ui = new UIManager();
    [SerializeField] ResourceManager _resource;
    PhotonDataManager _punData = new PhotonDataManager();
    CameraManager _camData = new CameraManager();
    
    public static FirebaseAughManager FirebaseAuth { get { return Instance._firebaseAuth; } }
    public static UserDataManager UserData { get { return Instance._userData; } }
    
    public static PlayerPointManager PointData { get {return Instance._pointData; } }
    public static RoundInfoManager RoundData { get { return Instance._roundData; } }
    public static SceneLoadManager SceneLoad { get { return Instance._sceneLoad; } }
    public static SoundManager Sound { get { return Instance._sound; } }

    public static UIManager UI { get { return Instance._ui; } }
    public static ResourceManager Resource { get { return Instance._resource; } }
    public static PhotonDataManager PunData { get { return Instance._punData; } }
    public static CameraManager CamData { get { return Instance._camData; } }
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

                s_instance = go.GetComponent<Managers>();
            }
            return s_instance;
        } 
    }
    public void Init()
    {
        _firebaseAuth.Init();
        _sceneLoad.Init();
        _sound = gameObject.GetComponentInChildren<SoundManager>();
        _sound.Init();
        s_instance = GetComponent<Managers>();
    }
    private void Start()
    {
        Init();
    }
    void OnDestroy()
    {
        if (s_instance == this)
        {
            s_instance = null;
        }
    }
}
