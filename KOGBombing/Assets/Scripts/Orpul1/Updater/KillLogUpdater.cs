using Photon.Realtime;
using UnityEngine;

public class KillLogUpdater : ObjectPool
{
    [SerializeField] Transform uiParent;
    protected override void Init()
    {
        parent = uiParent;
    }
    public void UpdateKillLog(KillLogPlayer[] logInfos)
    {
        PooledObject pool = GetPooledObject();
        if (pool == null) return;
        KillLogUIPresenter presenter = pool.gameObject.GetComponent<KillLogUIPresenter>();
        //presenter.transform.SetParent(uiParent);
        presenter.Initialize();
        presenter.SetKillLog(logInfos);
    }
}