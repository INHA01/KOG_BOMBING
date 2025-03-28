using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;
using Semin;
using Photon.Pun;
using Photon.Realtime;
namespace Orpul1
{
    public class RoundInfoManager
    {
        public int roundCount = 1;
        int[] teamScore = new int[2];
        int[] teamkillScore = new int[2];
        int[] teamMissionScore = new int[2];
        Dictionary<string, CharacterType> dicCharacterSelects = new Dictionary<string, CharacterType>();
        private WinnerTeam roundWinTeam;
        
        int[] playerMissionScores = new int[2];
        int[] playerKillScores = new int[2];
        int[] playerDeathScores = new int[2];

        public WinnerTeam RoundWinTeam
        {
            get
            {
                return roundWinTeam;
            }
        }
        public int[] TeamScore { get { return teamScore; } }
        public int[] TeamKillScore { get { return teamkillScore; } }
        public int[] TeamMissionScore{ get { return teamMissionScore; } }
        public Dictionary<string, CharacterType> CharacterSelects {  get { return dicCharacterSelects; } }

        public WinnerTeam WinTeam;
        public void Initialize()
        {
            for (int i = 0; i < 2; i++) 
            {
                teamScore[i] = 0;
                teamkillScore[i] = 0;
                teamMissionScore[i] = 0;
            }
            dicCharacterSelects.Clear();
            roundCount = 1;
            roundWinTeam = WinnerTeam.REDTEAM;
        }
        public void IncreaseTeamKillScore(ETeam type)
        {
            teamkillScore[(int)type] += 1;
        }
        public void IncreaseTeamMissionScore(ETeam type)
        {
            teamMissionScore[(int)type] += 1;
        }
        public void SetRoundWinTeam(WinnerTeam type)
        {
            roundWinTeam = type;
        }
        public void SetTeamScore(ETeam type,int score)
        {
            teamScore[(int)type] = score;
        }
        public void TeamRollSwitch()
        {
            int scoreTemp = teamScore[0];
            teamScore[0] = teamScore[1];
            teamScore[1] = scoreTemp;

            int killScore = teamkillScore[0];
            teamkillScore[0] = teamkillScore[1];
            teamkillScore[1] = killScore;

            int missionScore = teamMissionScore[0];
            teamMissionScore[0] = teamMissionScore[1];
            teamMissionScore[1] = missionScore;
        }

        public void SetSelectCharacter(string nickname, CharacterType type)
        {
            if(dicCharacterSelects.ContainsKey(nickname))
            {
                dicCharacterSelects[nickname] = type;
                return;
            }
            dicCharacterSelects.Add(nickname, type);
        }
        public void CalcWinTeam()
        {
            WinTeam = GetWinTeam();
        }
        private WinnerTeam GetWinTeam()
        {
            int result = teamScore[(int)WinnerTeam.REDTEAM] - teamScore[(int)WinnerTeam.BLUETEAM];
            if (result > 1)
                return WinnerTeam.REDTEAM;
            else if (result < 0)
                return WinnerTeam.BLUETEAM;

            return GetSameScoreWinTeam();
        }

        /// <summary>
        /// °ø°Ý ÆÀ ½Â¸®: 1,
        /// ¹æ¾î ÆÀ ½Â¸®: 0,
        /// µ¿Á¡: -1
        /// </summary>
        /// <returns>int</returns>
        private WinnerTeam GetSameScoreWinTeam()
        {
            WinnerTeam winnerTeam = CalcMissionPoint();
            if (winnerTeam == WinnerTeam.DRAW)
            {
                return CalcKillDeathScore();
            }
            return WinnerTeam.REDTEAM;
        }
        private WinnerTeam CalcMissionPoint()
        {
            Player[] players = PhotonNetwork.PlayerList;

            for (int i = 0; i < players.Length; i++)
            {
                PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
                ETeam team = (ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
                playerMissionScores[(int)team] += pointInfo.MissionPoint;
                playerKillScores[(int)team] += pointInfo.KillPoint;
                playerDeathScores[(int)team] += pointInfo.DeathPoint;
            }
            int scoreResult = playerMissionScores[(int)WinnerTeam.REDTEAM] - playerMissionScores[(int)WinnerTeam.BLUETEAM];

            if (scoreResult > 0)
            {
                return WinnerTeam.REDTEAM;
            }
            else if (scoreResult < 0)
            {
                return WinnerTeam.DRAW;
            }
            return WinnerTeam.BLUETEAM;
        }
        private WinnerTeam CalcKillDeathScore()
        {
            int redTeamScore = playerKillScores[(int)WinnerTeam.REDTEAM] / (playerDeathScores[(int)WinnerTeam.REDTEAM] + 1);
            int blueTeamScore = playerKillScores[(int)WinnerTeam.BLUETEAM] / (playerDeathScores[(int)WinnerTeam.BLUETEAM] + 1);
            if (redTeamScore > blueTeamScore)
                return WinnerTeam.REDTEAM;
            return WinnerTeam.BLUETEAM;
        }
    }

}
