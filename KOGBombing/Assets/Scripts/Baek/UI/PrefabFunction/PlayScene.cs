using Orpul1;
using System.Collections;
using System.Collections.Generic;
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
    [SerializeField] Sprite[] blueScoreImages;
    [SerializeField] Sprite[] redScoreImages;
    [SerializeField] Image blueScoreIcon;
    [SerializeField] Image redScoreIcon;
    [Header("Model")]
    [HideInInspector] public PlayerShooting weapon;
    Dictionary<string,TeamProfile> dicTeamProfile = new Dictionary<string,TeamProfile>();

    void Update()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
        string min = ((int)gameDirector.time / 60).ToString();
        if(min.Length == 1)
            min = "0" + min;
        string sec = ((int)gameDirector.time % 60).ToString();
        if (sec.Length == 1)
            sec = "0" + sec;
        timer.text = min + ":" + sec;

        if(GameDirector.redScore < 10)
            redScoreIcon.sprite = redScoreImages[GameDirector.redScore];
        if (GameDirector.blueScore < 10)
            blueScoreIcon.sprite = blueScoreImages[GameDirector.blueScore];
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
    public void UpdateProfile(string nickname, float hp, float defence , bool isLive)
    {
        if (!dicTeamProfile.ContainsKey(nickname)) return;
        dicTeamProfile[nickname].UpdateUI(hp, defence , isLive);
    }
}
