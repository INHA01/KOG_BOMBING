using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TeamProfile : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI nickName;
    public Image hp;
    public void Init()
    {
        nickName.text = Managers.UserData.userData.nickName;
    }
    public void UpdateUI()
    {
        
    }
}
