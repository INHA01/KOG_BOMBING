using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public abstract class PhotonUpdateController<T> : MonoBehaviour
{
    public abstract void UpdateInfo(T t, bool isRemove = false);
    public abstract void RemoveAllInfo();
}
