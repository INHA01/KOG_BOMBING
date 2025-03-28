using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using static UnityEngine.Rendering.VirtualTexturing.Debugging;

namespace BAEK
{ 
    public class UIFactory : FactoryBase
    {
        [SerializeField] GameObject[] _uiPrefabs = new GameObject[(int)UIKEY.Max];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfPrefabs.Length; i++)
            {
                if(i == (int)UIKEY.NONE || i == (int)UIKEY.Lobby || i == (int)UIKEY.Login) continue;
                var load = rfPrefabs[i].LoadAssetAsync();
                yield return load;
                _uiPrefabs[i] = load.Result;
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
