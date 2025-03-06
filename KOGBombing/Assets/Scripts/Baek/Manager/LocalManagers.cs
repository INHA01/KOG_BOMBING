using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LocalManagers : MonoBehaviour
{
    static LocalManagers s_instance;

    UIManager _ui = new UIManager();
    ResourceManager _resource = new ResourceManager();
    PhotonDataManager _punData = new PhotonDataManager();
    CameraManager _camData = new CameraManager();
    public static UIManager UI { get { return Instance._ui; } }
    public static ResourceManager Resource { get { return Instance._resource; } }
    public static PhotonDataManager PunData { get { return Instance._punData; } }
    public static CameraManager CamData { get { return Instance._camData; } }

    static LocalManagers Instance
    {
        get
        {
            if (s_instance == null)
            {
                s_instance = FindObjectOfType<LocalManagers>();
                if (s_instance == null)
                {
                    GameObject go = new GameObject { name = "@MyLocalManagers" };
                    s_instance = go.AddComponent<LocalManagers>();
                }
            }
            return s_instance;
        }
    }

    void Awake()
    {
        // 씬이 로드될 때마다 새로운 인스턴스를 만들도록 설정
        if (s_instance != null && s_instance != this)
        {
            Destroy(gameObject);
            return;
        }
        s_instance = this;
    }

    void Start()
    {
        // 초기화 작업을 여기에 추가
    }
    void OnDestroy()
    {
        // 인스턴스가 파괴될 때 s_instance를 null로 설정
        if (s_instance == this)
        {
            s_instance = null;
        }
    }
}
