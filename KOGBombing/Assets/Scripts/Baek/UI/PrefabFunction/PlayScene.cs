using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

public class PlayScene : MonoBehaviour
{
    [Header ("View")]
    [SerializeField] TextMeshProUGUI magazineCount;
    [SerializeField] Image chargeBar;
    [SerializeField] GameObject teamProfile;
    [Header("Model")]
    [HideInInspector] public PlayerShooting weapon;
    Dictionary<string,TeamProfile> dicTeamProfiles = new Dictionary<string, TeamProfile> ();
    TeamProfile profileUI;
    public PlayerBlackBoard blackboard;
    void Update()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
    }
    public void SetMine(PlayerBlackBoard blackBoard)
    {
        this.blackboard = blackBoard;
        GameObject go = null;
        //PhotonNetwork.Instantiate("Prefabs/UIPrefabs/Scene/PlayScene/Profile", Vector3.zero, Quaternion.identity);
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/Profile");
        go.transform.SetParent(teamProfile.transform);
        profileUI = go.GetComponent<TeamProfile>();
        profileUI.Init(blackBoard);
    }
    public void SetTeam(PlayerBlackBoard blackBoard)
    {
        this.blackboard = blackBoard;
        GameObject go = null;
        go =  Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/Profile");
        go.transform.SetParent(teamProfile.transform);
        TeamProfile profile = go.GetComponent<TeamProfile>();
        profile.Init(blackBoard);
        dicTeamProfiles.Add(blackBoard.nickname, profile);
    }
    public void UpdateProfile(string dicID, float hp, float defence)
    {
        dicTeamProfiles[dicID].UpdateUI(hp, defence);
    }
}
