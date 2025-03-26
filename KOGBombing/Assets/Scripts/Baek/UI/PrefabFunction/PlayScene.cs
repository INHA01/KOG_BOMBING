using Orpul1;
using BAEK;
using Photon.Pun;
using Photon.Pun.UtilityScripts;
using Photon.Realtime;
using Semin;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class PlayScene : UIPopup
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
    [SerializeField] GameObject killLogo;
    [SerializeField] KillLogUpdater killLogUpdater;
    Dictionary<int,TeamProfile> dicTeamProfile = new Dictionary<int,TeamProfile>();
    [Header("ScoreIcon")]
    public TextMeshProUGUI timer;
    [SerializeField] GameObject roundGuide;
    Sprite[] blueScoreImages = new Sprite[10];
    Sprite[] redScoreImages = new Sprite[10];
    List<Sprite[]> scoreImageList = new List<Sprite[]>();
    [SerializeField] Image[] scoreImgs;
    [Header("Map")]
    [SerializeField] GameObject miniMap;

    [Header("Skill")]
    public Image skillFade;
    [SerializeField] GameObject[] skillIcon = new GameObject[2];
    public TextMeshProUGUI skillCount;
    [Header("SubWeapon")]
    [SerializeField] public GameObject[] subWeaponFades = new GameObject[2];
    [SerializeField]Image subWeaponIcon;
    
    [HideInInspector] public PlayerShooting weapon;

    void Awake()
    {
        for (int i = 0; i < 10; i++)
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
        miniMap.SetActive(true);
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
    }
    public void OnExtractMap(InputValue value)
    {
        if (value.isPressed)
        {
            // 애니메이션 리셋
            bool isExtract = miniMap.GetComponent<Animator>().GetBool("Extract");   
            if(isExtract)
            {
                miniMap.GetComponent<Animator>().SetBool("Minimize", true);
                miniMap.GetComponent<Animator>().SetBool("Extract", false);
            }
            else
            {
                miniMap.GetComponent<Animator>().SetBool("Minimize", false);
                miniMap.GetComponent<Animator>().SetBool("Extract", true);
            }
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
        roundGuide.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Round 1";
    }
    public void PublishRound(int round)
    {
        GameObject roundText = roundGuide.transform.GetChild(0).gameObject;
        GameObject mission = roundGuide.transform.GetChild(1).gameObject;
        roundText.GetComponent<TextMeshProUGUI>().text = "Round " + round;
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        TextMeshProUGUI missionText = mission.GetComponent<TextMeshProUGUI>();
        if (team == ETeam.BLUETEAM)
        {
            missionText.text = "폭발을 저지하세요.";
            missionText.colorGradient = new VertexGradient(new Color32(0, 248, 248, 255), new Color32(0, 248, 248, 255), new Color32(0, 248, 248, 60), new Color32(0, 248, 248, 60));
        }
        else
        {
            missionText.text = "폭발을 실행하세요";
            missionText.colorGradient = new VertexGradient(Color.red, Color.red, new Color32(255, 0, 0, 60), new Color32(255, 0, 0, 60));
        }
        Animator animator = roundGuide.GetComponent<Animator>();
        animator.Rebind();
        animator.Play("RoundGuide", 0, 0);
    }
    public void SetTeam(PlayerStateData playerStateData)
    {
        GameObject go = null;
        go = Managers.Resource.Instantiate(FactoryType.SupportUI, (int)SupportUI.PlayProfile, teamProfile.transform);
        go.transform.localScale = Vector3.one;
        TeamProfile profile = go.GetComponent<TeamProfile>();
        profile.Init(playerStateData);
        dicTeamProfile.Add(playerStateData.playerIndex, profile);
    }
    public void UpdateKillLog(PlayerInfo[] logInfos)
    {
        killLogUpdater.UpdateKillLog(logInfos);
    }
    public void UpdateProfile(int key)
    {
        if (!dicTeamProfile.ContainsKey(key)) return;
        dicTeamProfile[key].UpdateUI();
    }
    public void UpdateScore(ETeam team, int score)
    {
        // 인덱스 값 넘음 10점 시
        if (score > 9) return;
        scoreImgs[(int)team].sprite = scoreImageList[(int)team][score]; 
    }
    public void SetSubWeaponIcon(WeaponType type)
    {
        PlayUI name = type == WeaponType.LANDMINE ? PlayUI.Landmine : PlayUI.Molotov;
        subWeaponIcon.sprite = Managers.Resource.LoadImg(ImgLoaderType.Play, (int)name);
    }
    public void SetSkillIcon(CharacterType type)
    {
        PlayUI name = type == CharacterType.Ned ? PlayUI.NedSkill : PlayUI.UniSkill;
        PlayUI activeName = type == CharacterType.Ned ? PlayUI.NedSkillActive : PlayUI.UniSkillActive;
        skillIcon[0].GetComponent<Image>().sprite = Managers.Resource.LoadImg(ImgLoaderType.Play, (int)activeName);
        skillIcon[1].GetComponent<Image>().sprite = Managers.Resource.LoadImg(ImgLoaderType.Play, (int)name);
        SetSkillActive(true);
    }
    public void SetSkillActive(bool isActive)
    {
        skillIcon[(int)SkillIcon.Active].SetActive(isActive);
        skillIcon[(int)SkillIcon.Cool].SetActive(!isActive);
    }
    public void ActiveKill()
    {
        StartCoroutine(DuringKill());
    }
    IEnumerator DuringKill()
    {
        if(killLogo.activeSelf)
        {
            killLogo.SetActive(false);
        }
        killLogo.SetActive(true);
        yield return new WaitForSeconds(3f);
        killLogo.SetActive(false);
    }
}
