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
    Dictionary<string,TeamProfile> dicTeamProfile = new Dictionary<string,TeamProfile>();
    [Header("ScoreIcon")]
    public TextMeshProUGUI timer;
    // ResourceManager 사용할지 고민 중
    Sprite[] blueScoreImages = new Sprite[10];
    Sprite[] redScoreImages = new Sprite[10];
    [SerializeField] Image blueScoreIcon;
    [SerializeField] Image redScoreIcon;
    [Header("Map")]
    [SerializeField] GameObject[] maps;
    [Header("Attack")]
    [HideInInspector] public PlayerShooting weapon;
    [SerializeField] public Image skillFade;
    [SerializeField] public TextMeshProUGUI skillCount;
    [SerializeField] public GameObject[] subWeaponFades = new GameObject[2];

    [SerializeField] float sensitivity = 100f;
    void Start()
    {
        for(int i = 0; i < 10; i++)
        {
            blueScoreImages[i] = Resources.Load<Sprite>($"UISettings/Play/Play_UI_Score/Number/T_GUI_Bg_Exit_Number_"+i.ToString()+"_Blue");
            redScoreImages[i] = Resources.Load<Sprite>($"UISettings/Play/Play_UI_Score/Number/T_GUI_Bg_Exit_Number_" + i.ToString() + "_Red");
        }
        blueScoreIcon.sprite = blueScoreImages[0];
        redScoreIcon.sprite = redScoreImages[0];
    }
    void OnDisable()
    {
        for (int i = 0; i < subWeaponFades.Length; i++)
        {
            subWeaponFades[i].SetActive(false);
        }
        maps[0].SetActive(true);
        maps[1].SetActive(false);
        blueScoreIcon.sprite = blueScoreImages[0];
        redScoreIcon.sprite = redScoreImages[0];
    }
    void FixedUpdate()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
        if(Input.GetKeyDown(KeyCode.M))
        {
            maps[0].SetActive(!maps[0].activeSelf);
            maps[1].SetActive(!maps[1].activeSelf);
        }
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
        go.transform.localScale = Vector3.one;
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
