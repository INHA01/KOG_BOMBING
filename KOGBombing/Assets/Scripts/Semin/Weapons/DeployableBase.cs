using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class DeployableBase : SupportWeaponBase
{
    public abstract override void SetWeapon(SupportWeaponInfo info);

    abstract protected IEnumerator PutAfterAnim();
}
