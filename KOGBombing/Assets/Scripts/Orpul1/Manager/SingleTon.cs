using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SingleTon<T> : MonoBehaviour where T : Component
{
    private static T instance;
    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                instance = FindObjectOfType<T>();
                if(instance == null)
                {
                    GameObject singleTonObj = new GameObject("SingleTonObj");
                    singleTonObj.name = typeof(T).Name;
                    T t = singleTonObj.AddComponent<T>();
                }
            }
            return instance;
        }
    }
    protected virtual void Awake()
    {
        if(instance != null)
        {
            Destroy(gameObject);
            return;
        }
        instance = this as T;
        DontDestroyOnLoad(gameObject);
        Initialize();
    }
    protected abstract void Initialize();
}
