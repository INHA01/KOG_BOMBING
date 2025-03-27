using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public class SupportAttackFactory : FactoryBase
    {
        [SerializeField] GameObject[] _supportAttackPrefabs = new GameObject[(int)SupportAttackPrefab.Max];

        public override void Init()
        {
            for (int i = 0; i < _supportAttackPrefabs.Length; i++)
            {
                rfPrefabs[i].LoadAssetAsync().Completed += (load) =>
                {
                    _supportAttackPrefabs[i] = load.Result;
                };
            }
        }
        public override T GetPrefab<T>(int index)
        {
            if (typeof(T) == typeof(GameObject))
            {
                return (T)(object)_supportAttackPrefabs[index];
            }
            return _supportAttackPrefabs[index].GetComponent<T>();
        }
    }
}
