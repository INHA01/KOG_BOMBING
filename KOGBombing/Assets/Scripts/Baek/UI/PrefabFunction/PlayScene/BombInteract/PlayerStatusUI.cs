using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayerStatusUI : MonoBehaviour
{
    enum ObjectType
    {
        BombCircle,
        BombCraft,
        Max
    }
    [SerializeField] PhotonView pv;
    [SerializeField] GameObject[] bombUIs = new GameObject[(int)ObjectType.Max];
    [SerializeField] TextMeshProUGUI playerName;
    void Awake()
    {
        playerName.text = pv.Owner.NickName;
    }
    public void ActiveInteract(bool isInteract)
    {
        bombUIs[(int)ObjectType.BombCircle].SetActive(isInteract);
    }
    public void BombInteracting(float fillAmount)
    { 
        if(bombUIs[(int)ObjectType.BombCraft].activeSelf)
        {
            Image circleImage = bombUIs[(int)ObjectType.BombCircle].GetComponent<Image>();
            circleImage.fillAmount = fillAmount;
            //bombCraft z값 Rotate 증가 , z값이 360이 되면 0으로 초기화
            bombUIs[(int)ObjectType.BombCraft].transform.Rotate(new Vector3(0, 0, 60) * Time.deltaTime);
            if (bombUIs[(int)ObjectType.BombCraft].transform.eulerAngles.z >= 360)
            {
                bombUIs[(int)ObjectType.BombCraft].transform.eulerAngles = new Vector3(0, 0, 0);
            }
        }
    }
}
