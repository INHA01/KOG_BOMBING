using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public class SupportUIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _supportUIPrefabs = new GameObject[(int)SupportUI.Max];

        public override void Init()
        {
            for (int i = 0; i < _supportUIPrefabs.Length; i++)
            {
                rfPrefabs[i].LoadAssetAsync().Completed += (load) =>
                {
                    _supportUIPrefabs[i] = load.Result;
                };
            }
        }
        public override T GetPrefab<T>(int index)
        {
            if (typeof(T) == typeof(GameObject))
            {
                return (T)(object)_supportUIPrefabs[index];
            }
            return _supportUIPrefabs[index].GetComponent<T>();
        }
    }
}
