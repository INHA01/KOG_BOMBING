using BAEK;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PingSystem : MonoBehaviour
{
    [Header("Ping Sounds")]
    [SerializeField] List<AudioClip> pingSoundList;
    [Header("Ping")]
    public Ping[] pings = new Ping[(int)PingCursorType.Max];
    [SerializeField] GameObject[] pingIcons = new GameObject[(int)PingCursorType.Max];
    [SerializeField] GameObject pingUI;
    public PingCursorType pingCursorType;
    Vector2 mousePos;
    ShowCursor showCursor;
    int eventCode = 98;
    RaiseEventOptions options = new RaiseEventOptions();
    SendOptions sendOptions = new SendOptions();
    private void OnEnable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= PunShowPing;
        PhotonNetwork.NetworkingClient.EventReceived += PunShowPing;
    }
    private void OnDisable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= PunShowPing;
    }
    void Start()
    {
        showCursor = GetComponent<ShowCursor>();
        for (int i = 0; i < (int)PingCursorType.Max; i++)
        {
            pings[i].Init();
        }
        options.Receivers = ReceiverGroup.All;
        sendOptions.Reliability = true;
        sendOptions.DeliveryMode = DeliveryMode.Reliable;
    }
    public void OnPing(InputValue value)
    {
        if (value.isPressed)
        {
            mousePos = Input.mousePosition;
            pingUI.SetActive(true);
            pingUI.transform.position = mousePos;
        }
        else
        {
            ShowPing(mousePos);
            pingUI.SetActive(false);
        }
    }
    public void ShowPing(Vector2 pos)
    {
        if (pingIcons[(int)pingCursorType].activeSelf) return;
        Vector3 pingPos = pings[(int)pingCursorType].GetPingPos(pos);
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        CharacterType characterType = (CharacterType)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.CHARACTER.ToString()];
        object[] sendDatas = new object[] { (byte)team, pingPos, (byte)pingCursorType , (byte)characterType};
        PhotonNetwork.RaiseEvent((byte)eventCode, sendDatas, options, sendOptions);
    }
    private void PunShowPing(EventData punData)
    {
        if (punData.Code != eventCode) return;
        object[] datas = (object[])punData.CustomData;
        byte team = (byte)datas[0];
        if (team != (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()]) return;
        Vector3 pingPos = (Vector3)datas[1];

        byte pingCursorType = (byte)datas[2];
        byte characterType = (byte)datas[3];
        pings[pingCursorType].ShowEffect(pingPos);
        pingIcons[(int)pingCursorType].SetActive(true);
        StartCoroutine(showCursor.ShowPingCursor(pingPos, pingIcons[(int)pingCursorType]));

        int soundIndex = (int)pingCursorType + (characterType * 4);
        Managers.Sound.PlayEffect(pingSoundList[soundIndex], EMixerGroup.UISOUND);
    }
}
