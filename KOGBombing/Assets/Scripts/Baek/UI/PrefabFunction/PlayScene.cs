using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayScene : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI magazineCount;
    [SerializeField] Image chargeBar;
    [HideInInspector] public PlayerShooting weapon;
    void Update()
    {
        magazineCount.text = weapon.MagazineCount + "/4";
        chargeBar.fillAmount = weapon.ReloadTime;
    }


}
