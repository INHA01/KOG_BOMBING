using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;
using Semin;
namespace Orpul1
{
    public class RoundInfoManager
    {

        int[] teamScore = new int[2];
        int[] teamkillScore = new int[2];
        int[] teamMissionScore = new int[2];
        Dictionary<string, CharacterType> dicCharacterSelects = new Dictionary<string, CharacterType>();
        private ETeam roundWinTeam;
        public ETeam RoundWinTeam
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

        public int WinTeam
        { 
            get 
            {
                int result = teamScore[(int)ETeam.REDTEAM] - teamScore[(int)ETeam.BLUETEAM];
                if (result > 1)
                    return 1;
                else if (result < 0)
                    return -1;

                return 0;
            } 
        }
        public void Initialize()
        {
            for (int i = 0; i < 2; i++) 
            {
                teamScore[i] = 0;
                teamkillScore[i] = 0;
                teamMissionScore[i] = 0;
            }
            dicCharacterSelects.Clear();
            roundWinTeam = ETeam.REDTEAM;
        }
        public void SetTeamKillScore(ETeam type, int score)
        {
            teamkillScore[(int)type] = score;
        }
        public void SetTeamMissionScore(ETeam type, int score)
        {
            teamMissionScore[(int)type] = score;
        }
        public void SetRoundWinTeam(ETeam type)
        {
            roundWinTeam = type;
        }
        public void SetTeamScore(ETeam type, int score)
        {
            teamScore[(int)type] = score;
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
    }

}
