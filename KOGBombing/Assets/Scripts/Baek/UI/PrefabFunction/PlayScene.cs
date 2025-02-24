using Orpul1;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayScene : MonoBehaviour
{
    [Header ("View")]
    [SerializeField] TextMeshProUGUI magazineCount;
    [SerializeField] Image chargeBar;
    [SerializeField] GameObject teamProfile;
    [Header("ScoreIcon")]
    //[HideInInspector] public PhotonOfflineMode gameDirector;
    [HideInInspector] public GameDirector gameDirector;
    [SerializeField] TextMeshProUGUI timer;
    // ResourceManager 사용할지 고민 중
    [SerializeField] Sprite[] blueScoreImages;
    [SerializeField] Sprite[] redScoreImages;
    [SerializeField] Image blueScoreIcon;
    [SerializeField] Image redScoreIcon;
    [Header("Map")]
    [SerializeField] GameObject[] maps;
    [Header("Model")]
    [HideInInspector] public PlayerShooting weapon;
    Dictionary<string,TeamProfile> dicTeamProfile = new Dictionary<string,TeamProfile>();

    [SerializeField] float sensitivity = 100f;

    void FixedUpdate()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
        if(Input.GetKeyDown(KeyCode.Comma))
        {
            maps[0].SetActive(!maps[0].activeSelf);
            maps[1].SetActive(!maps[1].activeSelf);
        }
       /* string min = ((int)gameDirector.time / 60).ToString();
        if(min.Length == 1)
            min = "0" + min;
        string sec = ((int)gameDirector.time % 60).ToString();
        if (sec.Length == 1)
            sec = "0" + sec;
        timer.text = min + ":" + sec;

        if(GameDirector.redScore < 10)
            redScoreIcon.sprite = redScoreImages[GameDirector.redScore];
        if (GameDirector.blueScore < 10)
            blueScoreIcon.sprite = blueScoreImages[GameDirector.blueScore];*/
    }
    public void Reset()
    {
        if (dicTeamProfile.Count == 0) return;
        for(int i=0; i<dicTeamProfile.Count; i++)
        {
            TeamProfile profile = dicTeamProfile.ElementAt(i).Value;
            Destroy(profile.gameObject);
        }
        dicTeamProfile.Clear();
    }
    public void SetTeam(PlayerBlackBoard blackBoard)
    {
        GameObject go = null;
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/Profile");
        go.transform.SetParent(teamProfile.transform);
        TeamProfile profile = go.GetComponent<TeamProfile>();
        profile.Init(blackBoard);
        dicTeamProfile.Add(blackBoard.nickname, profile);
    }
    public void UpdateProfile(string nickname)
    {
        if (!dicTeamProfile.ContainsKey(nickname)) return;
        dicTeamProfile[nickname].UpdateUI();
    }
    public void UpdateScore(ETeam team, int score)
    {
        if(team == ETeam.REDTEAM)
        {
            redScoreIcon.sprite = redScoreImages[score];
        }
        else if(team == ETeam.BLUETEAM)
        {
            blueScoreIcon.sprite = blueScoreImages[score];
        }
    }
}
