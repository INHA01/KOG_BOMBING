using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class ObjectPool :  MonoBehaviour
{
    [SerializeField] public int initPoolSize;
    [SerializeField] protected PooledObject objectToPool;
    [SerializeField] protected GameObject parentPrefab;
    protected Transform parent;

    protected Queue<PooledObject> queue;
    public int Count { get => queue.Count; }


    protected void Start()
    {
        SetupPool();
    }
    virtual protected void Init()
    {
        GameObject parentInstance = Instantiate(parentPrefab);
        parent = parentInstance.transform;
    }
    virtual protected void SetupPool()
    {
        Init();
        if (objectToPool == null || parent == null)
        {
            return;
        }
        queue = new Queue<PooledObject>();

        PooledObject instance = null;

        for (int i = 0; i < initPoolSize; i++)
        {
            instance = Instantiate(objectToPool);
            instance.Pool = this;
            instance.gameObject.SetActive(false);
            queue.Enqueue(instance);
            if (parentPrefab != null)
            {
                instance.transform.SetParent(parent);
            }
        }
    }

    public PooledObject GetPooledObject()
    {
        if (objectToPool == null)
        {
            return null;
        }
        if (queue.Count == 0)
        {
            PooledObject newInstance = Instantiate(objectToPool);
            newInstance.Pool = this;
            return newInstance;
        }

        PooledObject nextInstance = queue.Dequeue();
        nextInstance.gameObject.SetActive(true);
        return nextInstance;
    }

    public void ReturnToPool(PooledObject pooledObject)
    {
        queue.Enqueue(pooledObject);
        pooledObject.gameObject.SetActive(false);
    }
}
