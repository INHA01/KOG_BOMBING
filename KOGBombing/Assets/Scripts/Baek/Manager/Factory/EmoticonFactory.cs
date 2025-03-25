using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class EmoticonFactory : FactoryBase
    {
        [SerializeField] GameObject[] _emoticons = new GameObject[(int)EmoticonType.Max];
        public override T GetPrefab<T>(int index)
        {
            if (typeof(T) == typeof(GameObject))
            {
                return (T)(object)_emoticons[index];
            }
            return _emoticons[index].GetComponent<T>();
        }
    }
}

