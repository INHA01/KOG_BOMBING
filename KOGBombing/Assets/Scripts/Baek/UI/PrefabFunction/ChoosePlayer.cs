using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChoosePlayer : MonoBehaviour
{
    [SerializeField] GameObject[] players;
    [SerializeField] GameObject teamIconBack;
    GameObject go;
    private void Start()
    {
        go = Managers.Resource.Instantiate($"UIPrefabs/Scene/PlayScene/ChoosePlayer/IconBack");
        go.transform.SetParent(teamIconBack.transform);
    }
    public void Choosing(int index)
    {
        if(index == 0)
        {
            players[0].SetActive(true);
            players[1].SetActive(false);
            go.GetComponentInChildren<Image>().sprite = Resources.Load<Sprite>("UIPrefabs/Scene/PlayScene/ChoosePlayer/Profile_Ned");
        }
        else
        {
            players[0].SetActive(false);
            players[1].SetActive(true);
            go.GetComponentInChildren<Image>().sprite = Resources.Load<Sprite>("UIPrefabs/Scene/PlayScene/ChoosePlayer/Profile_Uni");
        }
    }
}
