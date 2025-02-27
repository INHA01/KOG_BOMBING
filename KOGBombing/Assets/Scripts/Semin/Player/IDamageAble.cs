using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamageAble
{
    public void OnDamaged(float damage, int playerIndex);
    public void OnRigidity(float time);

}
