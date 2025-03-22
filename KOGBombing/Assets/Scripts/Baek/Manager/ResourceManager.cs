using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResourceManager : MonoBehaviour
{
    [SerializeField] FactoryBase[] factories = new FactoryBase[(int)FactoryType.Max];
    public T Load<T>(FactoryType type, int index) where T : Object
    {
        T prefab = factories[(int)type].GetPrefab<T>(index);
        return prefab;
    }
    public T Load<T>(string path) where T : Object
    {
        return Resources.Load<T>(path);
    }
    public GameObject Instantiate(FactoryType type, int index, Transform parent = null)
    {
        GameObject prefab = factories[(int)type].GetPrefab<GameObject>(index);
        if (prefab == null)
        {
            Debug.Log($"Failed to load prefab");
            return null;
        }
        GameObject go = Instantiate(prefab, parent);
        int name = go.name.IndexOf("(Clone)");
        if (name > 0)
        {
            go.name = go.name.Substring(0, name);
        }
        return go;
    }
    public GameObject Instantiate(string path, Transform parent = null)
    {
        GameObject prefab = Load<GameObject>($"Prefabs/{path}");
        if (prefab == null)
        {
            Debug.Log($"Failed to load prefab: {path}");
            return null;
        }
        // Clone 텍스트 삭제
        GameObject go = Object.Instantiate(prefab, parent);
        int index = go.name.IndexOf("(Clone)");
        if(index > 0)
        {
            go.name = go.name.Substring(0, index);
        }
        return go;

    }

    public void Destroy(GameObject go)
    {
        if (go == null)
            return;
        Object.Destroy(go);
    }
}
