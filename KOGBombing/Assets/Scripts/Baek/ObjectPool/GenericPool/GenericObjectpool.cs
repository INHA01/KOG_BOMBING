using System;
using System.Collections.Generic;
using UnityEngine;

public class GenericObjectpool<T> where T : Component
{
    private readonly T prefab;
    private readonly Transform parent;
    public int initPoolSize = 36;
    private readonly Queue<T> queue;
    public int Count { get => queue.Count; }

    // 액션 대리자를 통해 외부에서 초기화 로직을 주입받음
    private readonly Action<T> _onGet;
    private readonly Action<T> _onRelease;

    public GenericObjectpool(T prefab, Transform parent, int poolSize, Action<T> onGet = null, Action<T> onRelease = null)
    {
        this.parent = parent;
        this.prefab = prefab;
        initPoolSize = poolSize;
        queue = new Queue<T>();
        _onGet = onGet;
        _onRelease = onRelease;

        SetupPool();
    }

    private void SetupPool()
    {
        if(parent == null || prefab == null)
        {
            Debug.LogError("Parent or Prefab is null. Cannot setup pool.");
            return;
        }

        for (int i = 0; i < initPoolSize; i++)
        {
            T instance = UnityEngine.Object.Instantiate(prefab, parent);
            instance.gameObject.SetActive(false);
            queue.Enqueue(instance);
            instance.transform.localPosition = Vector3.zero;
            instance.transform.localScale = Vector3.one;
        }
    }
    public void ResetPool()
    {
        foreach (var obj in queue)
        {
            UnityEngine.Object.Destroy(obj.gameObject);
        }
        queue.Clear();
        SetupPool();
    }

    public T GetPooledObject()
    {
        if (queue.Count == 0)
        {
            Debug.LogWarning("Pool is empty. Consider increasing the initial pool size.");
            return null;
        }
        T nextObject = queue.Dequeue();
        nextObject.gameObject.SetActive(true);
        _onGet?.Invoke(nextObject); // Get 시 실행할 로직이 있다면 호출
        return nextObject;
    }

    public void Release(T obj)
    {
        _onRelease?.Invoke(obj); // Release 시 실행할 로직이 있다면 호출
        obj.gameObject.SetActive(false);
        queue.Enqueue(obj);
    }
}
