using BAEK;
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
        EmoticonType[] emoticonTypes = new EmoticonType[(int)PingPos.Max];
        emoticonTypes[(int)PingPos.Top] = (EmoticonType)Managers.UserData.userData.emoticonT;
        emoticonTypes[(int)PingPos.Bottom] = (EmoticonType)Managers.UserData.userData.emoticonB;
        emoticonTypes[(int)PingPos.Right] = (EmoticonType)Managers.UserData.userData.emoticonR;
        emoticonTypes[(int)PingPos.Left] = (EmoticonType)Managers.UserData.userData.emoticonL;

        for(int i = 0; i < (int)PingPos.Max; i++)
        {
            string path =  emoticonTypes[i].ToString();
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
    }
}
