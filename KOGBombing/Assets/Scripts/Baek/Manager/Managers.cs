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
    public static Managers Instance 
    { 
        get 
        {
            if (s_instance == null)
                SetupInstance();
            return s_instance;
        } 
    }
    private static void SetupInstance()
    {
        GameObject go = GameObject.Find("@Managers");
        if (go == null)
        {
            go = new GameObject { name = "@Managers" };
            go.AddComponent<Managers>();
        }

        s_instance = go.GetComponent<Managers>();
    }
    public void Init()
    {
        _ui.Init();
        _firebaseAuth.Init();
        _sceneLoad.Init();
        _sound = gameObject.GetComponentInChildren<SoundManager>();
        _sound.Init();
    }
    private IEnumerator Start()
    {
        yield return _resource.Init();
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
