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
    [Header("Model")]
    [HideInInspector] public PlayerShooting weapon;
    List<TeamProfile> teamProfiles = new List<TeamProfile>();
    void Update()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
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
