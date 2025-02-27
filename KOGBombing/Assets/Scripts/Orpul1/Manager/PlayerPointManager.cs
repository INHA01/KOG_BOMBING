using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class PlayerPointManager
    {
        private Dictionary<string, PlayerPointInfo> dicPlayers = new Dictionary<string, PlayerPointInfo>();
        public void AddPlayerInfo(string key, PlayerPointInfo info)
        {
            if (dicPlayers.ContainsKey(key)) return;
            dicPlayers.Add(key, info);
        }
        public void RemovePlayerInfo(string key)
        {
            if (!dicPlayers.ContainsKey(key)) return;
            dicPlayers.Remove(key);
        }
        public PlayerPointInfo GetPlayerInfo(string key)
        {
            return dicPlayers[key];
        }
    }
}
