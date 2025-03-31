using Photon.Chat.Demo;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace Orpul1
{
    public class ChatFactory : FactoryBase
    {
        [SerializeField] GameObject chatPrefab;
        [SerializeField] Transform parent;
        public override T GetPrefab<T>(int index)
        {
            return Instantiate(chatPrefab, parent).GetComponent<T>();
        }
    }
}
