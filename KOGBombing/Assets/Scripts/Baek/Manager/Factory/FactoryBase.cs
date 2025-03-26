using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class FactoryBase : MonoBehaviour
{
    public abstract T GetPrefab<T>(int index);
}
