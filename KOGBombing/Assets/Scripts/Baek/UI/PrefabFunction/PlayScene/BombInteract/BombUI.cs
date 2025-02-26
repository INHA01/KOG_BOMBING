using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BombUI : MonoBehaviour
{
    [SerializeField] GameObject bombCircle;
    [SerializeField] GameObject bombCraft;

    public void ActiveInteract(bool isInteract)
    {
        bombCircle.SetActive(isInteract);
    }
    public void BombInteracting(float fillAmount)
    { 
        if(bombCraft.activeSelf)
        {
            Image circleImage = bombCircle.GetComponent<Image>();
            circleImage.fillAmount = fillAmount;
            //bombCraft z값 Rotate 증가 , z값이 360이 되면 0으로 초기화
            bombCraft.transform.Rotate(new Vector3(0, 0, 60) * Time.deltaTime);
            if (bombCraft.transform.eulerAngles.z >= 360)
            {
                bombCraft.transform.eulerAngles = new Vector3(0, 0, 0);
            }

        }
    }
}
