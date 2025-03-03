using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class PlayerPointManager
    {
        private Dictionary<string, PlayerPointInfo> dicPlayers = new Dictionary<string, PlayerPointInfo>();
        private List<string> myTeamPlayers = new List<string>();
        private StringBuilder bestPlayer = new StringBuilder();
        public StringBuilder BestPlayer { get { return bestPlayer; } }
        public void SetMyTeamPlayers()
        {
            Player[] players = PhotonNetwork.PlayerList;
            ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            for (int i = 0; i < players.Length; i++)
            {
                ETeam otherPlayerTeam = (ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
                if (myTeam != otherPlayerTeam) continue;
                myTeamPlayers.Add(players[i].NickName);
            }
        }
        public void Initialize()
        {
            dicPlayers.Clear();
            myTeamPlayers.Clear();
            bestPlayer.Clear();
        }
        public void SetBestPlayer()
        {
            float maxPoint = 0;
            int bestPlayerIndex = 0;
            for(int i=0; i<myTeamPlayers.Count; i++)
            {
                float deathPoint = dicPlayers[myTeamPlayers[i]].DeathPoint;
                float killPoint = dicPlayers[myTeamPlayers[i]].KillPoint;
                float assistPoint = dicPlayers[myTeamPlayers[i]].AsistPoint;
                float total = (killPoint + assistPoint) / (deathPoint + 1);
                if (maxPoint < total) 
                {
                    bestPlayerIndex = i;
                    maxPoint = total;
                }
            }
            bestPlayer.Append(myTeamPlayers[bestPlayerIndex]);
            Debug.Log($"bestPlayer {BestPlayer.ToString()}");
        }
        
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
