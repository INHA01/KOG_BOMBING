using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
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
        public void AddPoint(string key, EPointType type)
        {
            int score = 0;
            switch (type)
            {
                case EPointType.KILL:
                    score = dicPlayers[key].KillPoint;
                    dicPlayers[key].SetKillPoint(score + 1);
                    break;
                case EPointType.DEATH:
                    score = dicPlayers[key].DeathPoint;
                    dicPlayers[key].SetDeathPoint(score + 1);
                    break;
                case EPointType.ASSIST:
                    score = dicPlayers[key].AsistPoint;
                    dicPlayers[key].SetAsistePoint(score + 1);
                    break;
                case EPointType.MISSION:
                    score = dicPlayers[key].MissionPoint;
                    dicPlayers[key].SetMissionPoint(score + 1);
                    break;
            }
        }

    }
}
