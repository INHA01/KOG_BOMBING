using BAEK;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class Emoticon : UIPopup
{
    [SerializeField] Transform emoticonPos;
    [SerializeField] GameObject pingUI;
    [SerializeField] Image[] emoticonImage = new Image[(int)PingPos.Max];
    GameObject[] emoticons = new GameObject[(int)PingPos.Max];
    public PingPos pingPos = PingPos.Left;
    Vector2 mousePos;
    void Start()
    {
        Canvas canvas = Util.GetOrAddComponent<Canvas>(gameObject);
        canvas.sortingOrder = 30000;
        InitImoticon();
    }
    public void InitImoticon()
    {
        EmoticonType emoticonType;
        for(int i = 0; i < (int)PingPos.Max; i++)
        {
            emoticonType = (EmoticonType)Managers.UserData.userData.emoticon[i];
            string path = emoticonType.ToString();
            emoticonImage[i].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + path);
            emoticons[i] = Managers.Resource.Instantiate("UIPrefabs/Emoticon/" + path, emoticonPos);
            emoticons[i].SetActive(false);
        }
    }
    public void OnEmoticon(InputValue value)
    {
        if (value.isPressed)
        {
            mousePos = Input.mousePosition;
            pingUI.SetActive(true);
            pingUI.transform.position = mousePos;
        }
        else
        {
            ShowEmoticon(mousePos);
            pingUI.SetActive(false);
        }
    }
    void ShowEmoticon(Vector2 pos)
    {
        if(emoticons[(int)pingPos].activeSelf) return;
        
        emoticons[(int)pingPos].transform.position = pos;
        emoticons[(int)pingPos].SetActive(true);
        StartCoroutine(ShowingEmotincon(emoticons[(int)pingPos]));
    }
    IEnumerator ShowingEmotincon(GameObject go)
    {
        float time = 0;
        go.transform.position = Input.mousePosition;
        GameObject punEmoticonObj = PunShowingEmoticon();
        while (true)
        {
            time += Time.deltaTime;
            go.transform.Translate(Vector3.up * Time.deltaTime * 100);

            if (time > 1.5)
            {
                go.SetActive(false);
                break;
            }
            yield return null;
        }
        PunDestoryObject(punEmoticonObj);
    }
    private GameObject PunShowingEmoticon()
    {
        if (!PhotonNetwork.InRoom) return null;
        EmoticonType emoticon = (EmoticonType)Managers.UserData.userData.emoticon[(int)pingPos];
        string path = "Prefabs/UIPrefabs/Emoticon/" + emoticon.ToString();
        GameObject obj = PhotonNetwork.Instantiate(path, Vector3.zero, Quaternion.Euler(0, 0, 0));
        return obj;
    }
    private void PunDestoryObject(GameObject obj)
    {
        if (!PhotonNetwork.InRoom) return;
        PhotonNetwork.Destroy(obj);
    }

}
