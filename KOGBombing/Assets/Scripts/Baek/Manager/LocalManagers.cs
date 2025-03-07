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
        // ���� �ε�� ������ ���ο� �ν��Ͻ��� ���鵵�� ����
        if (s_instance != null && s_instance != this)
        {
            Destroy(gameObject);
            return;
        }
        s_instance = this;
    }

    void Start()
    {
        // �ʱ�ȭ �۾��� ���⿡ �߰�
    }
    void OnDestroy()
    {
        // �ν��Ͻ��� �ı��� �� s_instance�� null�� ����
        if (s_instance == this)
        {
            s_instance = null;
        }
    }
}
