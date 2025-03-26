using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using Unity.VisualScripting;
using UnityEngine;

namespace Orpul1
{
    public class PlayerPointManager
    {
        private Dictionary<string, PlayerPointInfo> dictPlayers = new Dictionary<string, PlayerPointInfo>();
        private List<string> myTeamPlayers = new List<string>();
        private List<string> otherTeamPlayers = new List<string>();

        private StringBuilder bestPlayer = new StringBuilder();
        public StringBuilder BestPlayer { get { return bestPlayer; } }
        public List<string> MyTeamPlayers { get { return myTeamPlayers; } } 
        public List<string> OtherTeamPlayers { get { return otherTeamPlayers; } } 
        public void SetTeamPlayers()
        {
            Player[] players = PhotonNetwork.PlayerList;
            ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            for (int i = 0; i < players.Length; i++)
            {
                ETeam otherPlayerTeam = (ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
                if (myTeam != otherPlayerTeam)
                {
                    otherTeamPlayers.Add(players[i].NickName);
                }
                else
                {
                    myTeamPlayers.Add(players[i].NickName);
                }
            }
        }
        public void Initialize()
        {
            dictPlayers.Clear();
            myTeamPlayers.Clear();
            bestPlayer.Clear();
            otherTeamPlayers.Clear();
        }
        public void SetBestPlayer()
        {
            float maxPoint = 0;
            int bestPlayerIndex = 0;
            for(int i=0; i<myTeamPlayers.Count; i++)
            {
                float deathPoint = dictPlayers[myTeamPlayers[i]].DeathPoint;
                float killPoint = dictPlayers[myTeamPlayers[i]].KillPoint;
                float assistPoint = dictPlayers[myTeamPlayers[i]].AsistPoint;
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
            if (dictPlayers.ContainsKey(key)) return;
            dictPlayers.Add(key, info);
        }
        public void RemovePlayerInfo(string key)
        {
            if (!dictPlayers.ContainsKey(key)) return;
            dictPlayers.Remove(key);
        }
        public PlayerPointInfo GetPlayerInfo(string key)
        {
            return dictPlayers[key];
        }
        public void AddPoint(string key, EPointType type)
        {
            int score = 0;
            switch (type)
            {
                case EPointType.KILL:
                    score = dictPlayers[key].KillPoint;
                    dictPlayers[key].SetKillPoint(score + 1);
                    break;
                case EPointType.DEATH:
                    score = dictPlayers[key].DeathPoint;
                    dictPlayers[key].SetDeathPoint(score + 1);
                    break;
                case EPointType.ASSIST:
                    score = dictPlayers[key].AsistPoint;
                    dictPlayers[key].SetAsistePoint(score + 1);
                    break;
                case EPointType.MISSION:
                    score = dictPlayers[key].MissionPoint;
                    dictPlayers[key].SetMissionPoint(score + 1);
                    break;
            }
        }

    }
}
