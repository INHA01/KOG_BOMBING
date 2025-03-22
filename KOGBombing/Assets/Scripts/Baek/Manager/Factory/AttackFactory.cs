using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class AttackFactory : FactoryBase
    {
        [SerializeField] GameObject[] _attackPrefabs = new GameObject[(int)AttackPrefab.Max];

        public override T GetPrefab<T>(int index)
        {
            T prefab = _attackPrefabs[index].GetComponent<T>();
            return prefab;
        }
    }
}
