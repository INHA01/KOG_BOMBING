using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class UIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _uiPrefabs = new GameObject[(int)UIKEY.Max];
        
        public override GameObject GetPrefab(int index)
        {
            return _uiPrefabs[index];
        }
    }
}
