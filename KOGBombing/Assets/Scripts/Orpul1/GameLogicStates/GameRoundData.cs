using System;
using Orpul1;
using Photon.Pun;
using UnityEngine;


namespace Orpul1
{
    public enum RoundEndType
    {
        NONE,
        BOMBEXPLOSION,
        BOMBCLEAR,
        BOMBSET,

        TIMEOVER,
        GAMEEND,
        ALLDIEATTACK,
        ALLDIEDEFENCE,
    }
    [Serializable]
    public class GameRoundData
    {
        private int[] teamScores = new int[2] { 0, 0 }; 
        private int[] teamCounts = new int[2] { 0, 0 };
        private int[] switchRoundScores = new int[2] { 0, 0 };
        private int processRoundCnt = 0; 
        public int[] TeamScores { get { return teamScores; } }
        public int[] TeamCounts { get { return teamCounts; } }
        public int ProcessRoundCnt { get { return processRoundCnt; } }
        public int maxRound = 10;
        public int winRound = 4;
        public int switchRound = 2;
        public bool isAlreadySwitchRoll = false;
        bool isSetBomb = false;
        bool isEndRound = false;
        TeamUIController teamUIController;
        RoundEndType roundEndType = RoundEndType.NONE;
        public RoundEndType EndRoundType { get { return roundEndType; } }
        public bool IsEndRound { get { return isEndRound; } }
        
        
        public GameRoundData()
        {
            for (int i = 0; i < 2; i++)
            {
                teamScores[i] = 0;
                teamCounts[i] = 0;
            }
        }
        public void Initialize(TeamUIController teamUIController)
        {
            isEndRound = false;
            isSetBomb = false;
            this.teamUIController = teamUIController;
            roundEndType = RoundEndType.NONE;
        }
        public void SetTeamCount(int teamType, int count)
        {
            teamCounts[teamType] = count;
        }
        public void SetDecreaseTeamCount(int teamType)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            teamCounts[teamType]--;
            Debug.Log("DecreaseTeamCount");
            if (teamCounts[(int)ETeam.BLUETEAM] == 0)
            {
                roundEndType = RoundEndType.ALLDIEDEFENCE;
                isEndRound = true;
            }
            if (teamCounts[teamType] == 0&&!isSetBomb)
            {
                Debug.Log("EXTERMINATE Team");
                roundEndType = RoundEndType.ALLDIEATTACK + teamType;
                isEndRound = true;
            }
        }

        public void SetEndRound(RoundEndType endType, bool isEndRound)
        {
            Debug.Log($"endType {endType.ToString()}, isEndRound {isEndRound}");
            this.roundEndType = endType;
            this.isEndRound = isEndRound;
        }
        public void SetTeamScore()
        {
            switch(roundEndType)
            {
                //Defence team win condition
                case RoundEndType.TIMEOVER:
                case RoundEndType.BOMBCLEAR:
                case RoundEndType.ALLDIEATTACK:
                    Managers.RoundData.SetRoundWinTeam(ETeam.BLUETEAM);
                    switchRoundScores[(int)ETeam.BLUETEAM]++;
                    teamScores[(int)ETeam.BLUETEAM]++;
                    Managers.RoundData.SetTeamScore(ETeam.BLUETEAM, teamScores[(int)ETeam.BLUETEAM]);
                    break;

                //Attack team win condition
                case RoundEndType.BOMBEXPLOSION:
                case RoundEndType.ALLDIEDEFENCE:
                    Managers.RoundData.SetRoundWinTeam(ETeam.REDTEAM);
                    switchRoundScores[(int)ETeam.REDTEAM]++;
                    teamScores[(int)ETeam.REDTEAM]++;
                    Managers.RoundData.SetTeamScore(ETeam.REDTEAM, teamScores[(int)ETeam.REDTEAM]);
                    break;
            }

            // >> TODO : 공수 교대 시 팀 점수 ui 갱신
            teamUIController.UpdateTeamScore(ETeam.REDTEAM, teamScores[(int)ETeam.REDTEAM]);
            teamUIController.UpdateTeamScore(ETeam.BLUETEAM, teamScores[(int)ETeam.BLUETEAM]);
            roundEndType = RoundEndType.NONE;
        }
        public void SwapTeam()
        {
            int score = teamScores[(int)ETeam.REDTEAM];
            teamScores[(int)ETeam.REDTEAM] = teamScores[(int)ETeam.BLUETEAM];
            teamScores[(int)ETeam.BLUETEAM] = score;
            
            Debug.Log("Swap Team Score");
        }
        public void RoundTimeOver()
        {
            roundEndType = RoundEndType.TIMEOVER;
            isEndRound = true;
        }
        public void SetBomb()
        {
            isSetBomb = true;
        }
        public EGameState GetNextState()
        {
            if (IsEndGame())
            {
                teamUIController.EndRound();
                Managers.RoundData.SetTeamScore(ETeam.BLUETEAM, teamScores[(int)ETeam.BLUETEAM]);
                Managers.RoundData.SetTeamScore(ETeam.REDTEAM, teamScores[(int)ETeam.REDTEAM]);
                return EGameState.GAMEEND;
            }

            processRoundCnt++;
            if (IsNextRound())
                return EGameState.ROUNDWAIT;
            else
            {
                SwapTeam();
                SetTeamScore();
                return EGameState.SWITCHTEAMROLL;
            }
        }

        private bool IsEndGame()
        {
            float scoreGap = Mathf.Abs(teamScores[(int)ETeam.REDTEAM] - teamScores[(int)ETeam.BLUETEAM]);

            if (scoreGap >= winRound) return true;
            if (teamScores[(int)ETeam.REDTEAM] >= maxRound || teamScores[(int)ETeam.BLUETEAM] >= maxRound) return true;
            return false;
        }
        private bool IsNextRound()
        {
            int switchRollScore = Mathf.Max(teamScores[(int)ETeam.REDTEAM], teamScores[(int)ETeam.BLUETEAM]);
            if (switchRoundScores[(int)ETeam.BLUETEAM] == 3 || switchRoundScores[(int)ETeam.REDTEAM] == 3) 
            {
                switchRoundScores[(int)ETeam.REDTEAM] = 0;
                switchRoundScores[(int)ETeam.BLUETEAM] = 0;
                return false;
            }
            return true;
        }
        public void RemoveEvents()
        {
            if (teamUIController != null) 
                teamUIController.EndRound();
        }
    }
}