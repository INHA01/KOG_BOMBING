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
    [HideInInspector] public PhotonOfflineMode gameDirector;
    [SerializeField] TextMeshProUGUI timer;
    [SerializeField] Sprite[] blueScoreImages;
    [SerializeField] Sprite[] redScoreImages;
    [SerializeField] Image blueScoreIcon;
    [SerializeField] Image redScoreIcon;
    [Header("Model")]
    [HideInInspector] public PlayerShooting weapon;
    List<TeamProfile> teamProfiles = new List<TeamProfile>();

    bool optionOpen = false;
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

        if(gameDirector.redScore < 10)
            redScoreIcon.sprite = redScoreImages[gameDirector.redScore];
        if (gameDirector.blueScore < 10)
            blueScoreIcon.sprite = blueScoreImages[gameDirector.blueScore];
        if(Input.GetKeyDown(KeyCode.Escape))
            if(optionOpen)
            {
                Managers.UI.CloseSceneUI();
                optionOpen = false;
            }
            else
            {
                Managers.UI.ShowSceneUI<UIScene>("OptionCanvas");
                optionOpen = true;
            }
    }
    public void SetTeam(float hp)
    {
        GameObject go = null;
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/Profile");
        go.transform.SetParent(teamProfile.transform);
        TeamProfile profile = go.GetComponent<TeamProfile>();
        profile.Init(hp);
        teamProfiles.Add(profile);
    }
}
