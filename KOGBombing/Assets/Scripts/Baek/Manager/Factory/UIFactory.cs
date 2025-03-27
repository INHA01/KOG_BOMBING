using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class UIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _uiPrefabs = new GameObject[(int)UIKEY.Max];

        public override void Init()
        {
            for (int i = 0; i < _uiPrefabs.Length; i++)
            {
                rfPrefabs[i].LoadAssetAsync().Completed += (load) =>
                {
                    _uiPrefabs[i] = load.Result;
                };
            }
        }

        public override T GetPrefab<T>(int index)
        {
            if (typeof(T) == typeof(GameObject))
            {
                return (T)(object)_uiPrefabs[index];
            }
            return _uiPrefabs[index].GetComponent<T>();
        }
    }
}
