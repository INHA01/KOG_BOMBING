using BAEK;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
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
    Vector2 canvasPos;
    RaiseEventOptions optoins = new RaiseEventOptions();
    void Start()
    {
        optoins.Receivers = ReceiverGroup.All;
        Canvas canvas = Util.GetOrAddComponent<Canvas>(gameObject);
        canvasPos = canvas.transform.position;
        canvas.sortingOrder = 30000;
        InitImoticon();
    }
    private void OnEnable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= PunEmoticon;
        PhotonNetwork.NetworkingClient.EventReceived += PunEmoticon;
    }
    private void OnDisable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= PunEmoticon;
    }
    public void InitImoticon()
    {
        EmoticonType emoticonType;
        for(int i = 0; i < (int)PingPos.Max; i++)
        {
            emoticonType = (EmoticonType)Managers.UserData.userData.emoticon[i];
            emoticons[i] = Managers.Resource.Instantiate(FactoryType.Emoticon, (int)emoticonType, emoticonPos);
            emoticons[i].SetActive(false);
            emoticonImage[i].sprite = emoticons[i].GetComponent<Image>().sprite;
        }
    }
    public void OnEmoticon(InputValue value)
    {
        if (!PhotonNetwork.InRoom) return;
        if (value.isPressed)
        {
            mousePos = Input.mousePosition;

            pingUI.SetActive(true);
            pingUI.transform.position = mousePos;
        }
        else
        {
            //ShowEmoticon(mousePos);
            pingUI.SetActive(false);
            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            object[] sendDatas = new object[] { Managers.UserData.userData.emoticon[(int)pingPos], mousePos, mTeam };
            PhotonNetwork.RaiseEvent((int)PunEventType.EMOTICON, sendDatas, optoins, SendOptions.SendReliable);
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
        while (true)
        {
            time += Time.deltaTime;
            go.transform.Translate(Vector3.up * Time.deltaTime * 100);

            if (time > 1.5)
            {
                Destroy(go);
                break;
            }
            yield return null;
        }
    }
    private void PunEmoticon(EventData punEvent)
    {
        if (punEvent.Code != (int)PunEventType.EMOTICON) return;
        object[] receiveDatas = (object[])punEvent.CustomData;
        ETeam team = (ETeam)receiveDatas[2];
        if (team != (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()]) return;
        int emoticonType = (int)receiveDatas[0];
        Vector2 emoticonPosi = (Vector2)receiveDatas[1];

        EmoticonType emoticonPath = (EmoticonType)emoticonType;
        GameObject emoticon = Managers.Resource.Instantiate(FactoryType.Emoticon, (int)emoticonPath, emoticonPos);
        emoticon.transform.position = emoticonPosi;
        StartCoroutine(ShowingEmotincon(emoticon));
    }

}
