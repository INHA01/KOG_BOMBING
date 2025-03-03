using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayScene : MonoBehaviour
{
    enum SkillIcon
    {
        Active,
        Cool,
        Max
    }
    [Header ("View")]
    [SerializeField] TextMeshProUGUI magazineCount;
    [SerializeField] Image chargeBar;
    [SerializeField] GameObject teamProfile;
    Dictionary<string,TeamProfile> dicTeamProfile = new Dictionary<string,TeamProfile>();
    [Header("ScoreIcon")]
    public TextMeshProUGUI timer;
    Sprite[] blueScoreImages = new Sprite[10];
    Sprite[] redScoreImages = new Sprite[10];
    List<Sprite[]> scoreImageList = new List<Sprite[]>();
    [SerializeField] Image[] scoreImgs;
    [Header("Map")]
    [SerializeField] GameObject[] maps;

    [Header("Skill")]
    public Image skillFade;
    [SerializeField] GameObject[] skillIcon = new GameObject[2];
    public TextMeshProUGUI skillCount;
    [Header("SubWeapon")]
    [SerializeField] public GameObject[] subWeaponFades = new GameObject[2];
    [SerializeField]Image subWeaponIcon;
    
    [HideInInspector] public PlayerShooting weapon;

    [SerializeField] float sensitivity = 100f;
    void Awake()
    {
        for(int i = 0; i < 10; i++)
        {
            blueScoreImages[i] = Resources.Load<Sprite>($"UISettings/Play/Play_UI_Score/Number/T_GUI_Bg_Exit_Number_"+i.ToString()+"_Blue");
            redScoreImages[i] = Resources.Load<Sprite>($"UISettings/Play/Play_UI_Score/Number/T_GUI_Bg_Exit_Number_" + i.ToString() + "_Red");
        }
        scoreImageList.Add(redScoreImages);
        scoreImageList.Add(blueScoreImages);
        scoreImgs[(int)ETeam.REDTEAM].sprite = scoreImageList[(int)ETeam.REDTEAM][0];
        scoreImgs[(int)ETeam.BLUETEAM].sprite = scoreImageList[(int)ETeam.BLUETEAM][0];
    }
    void OnEnable()
    {
        for (int i = 0; i < subWeaponFades.Length; i++)
        {
            subWeaponFades[i].SetActive(false);
        }
        maps[0].SetActive(true);
        maps[1].SetActive(false);
        scoreImgs[(int)ETeam.REDTEAM].sprite = scoreImageList[(int)ETeam.REDTEAM][0];
        scoreImgs[(int)ETeam.BLUETEAM].sprite = scoreImageList[(int)ETeam.BLUETEAM][0];
    }
    void FixedUpdate()
    {
        // 호출 순서 엉켜서 에러 발생 weapon에 넣어주기 전에 호출되는 듯?
        if (weapon != null)
        {
            magazineCount.text = weapon.MagazineCount + "/4";
            chargeBar.fillAmount = weapon.ReloadTime;
        }
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
        // 인덱스 값 넘음 10점 시
        if (score > 9) return;
        scoreImgs[(int)team].sprite = scoreImageList[(int)team][score]; 
    }
    public void SetSubWeaponIcon(WeaponType type)
    {
        string name = type == WeaponType.LANDMINE ? "Landmine" : "Grenade_Flash";
        subWeaponIcon.sprite = Managers.Resource.Load<Sprite>($"UISettings/Play/Play_UI_Item/T_Gui_Icon_Consumables_{name}");
    }
    public void SetSkillIcon(CharacterType type)
    {
        string name = type == CharacterType.Ned ? "Ned" : "Uni";
        skillIcon[0].GetComponent<Image>().sprite = Managers.Resource.Load<Sprite>($"UISettings/Play/Play_UI_Skill/Play_UI_{name}_Skill_Active");
        skillIcon[1].GetComponent<Image>().sprite = Managers.Resource.Load<Sprite>($"UISettings/Play/Play_UI_Skill/Play_UI_{name}_Skill");
        SetSkillActive(true);
    }
    public void SetSkillActive(bool isActive)
    {
        skillIcon[(int)SkillIcon.Active].SetActive(isActive);
        skillIcon[(int)SkillIcon.Cool].SetActive(!isActive);
    }
}
