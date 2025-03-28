using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public class SupportUIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _supportUIPrefabs = new GameObject[(int)SupportUI.Max];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfPrefabs.Length; i++)
            {
                var load = rfPrefabs[i].LoadAssetAsync();
                yield return load;
                _supportUIPrefabs[i] = load.Result;
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
