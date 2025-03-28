using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class EmoticonFactory : FactoryBase
    {
        [SerializeField] GameObject[] _emoticons = new GameObject[(int)EmoticonType.Max];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfPrefabs.Length; i++)
            {
                var load = rfPrefabs[i].LoadAssetAsync();
                yield return load;
                _emoticons[i] = load.Result;
            }
        }
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

