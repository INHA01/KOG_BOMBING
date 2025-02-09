using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamageAble
{
    public void OnDamaged(float damage);
    public void OnRigidity(float time);

}
