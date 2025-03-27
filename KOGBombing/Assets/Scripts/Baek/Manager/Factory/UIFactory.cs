using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace BAEK
{ 
    public class UIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _uiPrefabs = new GameObject[(int)UIKEY.Max];
        IEnumerator Start()
        {
            for(int i =0; i< rfPrefabs.Length; i++)
            {
                var load = rfPrefabs[i].LoadAssetAsync();
                yield return load;
            }
            Init();
        }

        public override void Init()
        {
            for (int i = 1; i < _uiPrefabs.Length; i++)
            {
                if(i == (int)UIKEY.Lobby || i == (int)UIKEY.Login) continue;
                _uiPrefabs[i] = rfPrefabs[i].Asset as GameObject;
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
