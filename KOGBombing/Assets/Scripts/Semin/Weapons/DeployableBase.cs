using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class DeployableBase : SupportWeaponBase
{
    public abstract override void SetWeapon(SupportWeaponInfo info);

    public override void Use()
    {
        playerData.pv.RPC("PutConsum", RpcTarget.AllBuffered);
    }
    [PunRPC]
    public virtual void PutConsum()
    {
        StartCoroutine(PutAfterAnim());
    }

    abstract protected IEnumerator PutAfterAnim();
}
