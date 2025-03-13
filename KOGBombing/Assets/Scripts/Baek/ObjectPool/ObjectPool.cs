using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public abstract class ObjectPool :  MonoBehaviour , IDestroyAble
{
    public int initPoolSize = 36;
    [SerializeField] PooledObject objectToPool;
    [SerializeField] protected GameObject parentPrefab;
    protected Transform parent;

    Queue<PooledObject> queue;
    public int Count { get => queue.Count; }


    protected virtual void Start()
    {
        SetupPool();
    }
    virtual protected void Init()
    {
        if (parentPrefab == null) return;
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
            instance.transform.SetParent(parent);
            instance.transform.localPosition = Vector3.zero;
            instance.transform.localScale = Vector3.one;
        }
    }

    public void SetObjectToPool(PooledObject objectToPool)
    {
        this.objectToPool = objectToPool;
    }

    public void SetParentPrefab(GameObject parentPrefab)
    {
        this.parentPrefab = parentPrefab;
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
    public void DoDestory()
    {
        Destroy(parent.gameObject);
    }
}
