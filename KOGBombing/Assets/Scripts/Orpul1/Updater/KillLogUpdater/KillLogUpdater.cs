using Photon.Realtime;
using UnityEngine;
using Orpul1;
public class KillLogUpdater : ObjectPool
{
    [SerializeField] Transform uiParent;
    protected override void Init()
    {
        parent = uiParent;
    }
    public void UpdateKillLog(PlayerInfo[] logInfos)
    {
        PooledObject pool = GetPooledObject();
        if (pool == null) return;
        KillLogUIPresenter presenter = pool.gameObject.GetComponent<KillLogUIPresenter>();
        //presenter.transform.SetParent(uiParent);
        presenter.Initialize();
        presenter.SetKillLog(logInfos);
    }
}