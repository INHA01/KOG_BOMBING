using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class AttackFactory : FactoryBase
    {
        [SerializeField] GameObject[] _attackPrefabs = new GameObject[(int)AttackPrefab.Max];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfPrefabs.Length; i++)
            {
                var load = rfPrefabs[i].LoadAssetAsync();
                yield return load;
                _attackPrefabs[i] = load.Result;
            }
        }
        public override T GetPrefab<T>(int index)
        {
            if(typeof(T) == typeof(GameObject))
            {
                return (T)(object)_attackPrefabs[index];
            }
            return _attackPrefabs[index].GetComponent<T>();
        }
    }
}
