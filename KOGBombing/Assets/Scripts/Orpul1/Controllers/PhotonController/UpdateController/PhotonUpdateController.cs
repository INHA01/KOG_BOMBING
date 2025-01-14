using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public abstract class PhotonUpdateController<T> : MonoBehaviour, IInfoUpdateAble<T>
{
    public abstract void UpdateInfo(T t);
}
