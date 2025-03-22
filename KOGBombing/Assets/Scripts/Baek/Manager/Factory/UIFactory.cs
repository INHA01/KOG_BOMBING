using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class UIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _uiPrefabs = new GameObject[(int)UIKEY.Max];
        
        public override T GetPrefab<T>(int index)
        {
            T prefab = _uiPrefabs[index].GetComponent<T>();
            return prefab;
        }
    }
}
