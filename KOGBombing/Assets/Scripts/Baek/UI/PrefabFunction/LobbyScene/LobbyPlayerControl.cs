using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using Semin;
using UnityEngine.UIElements;

public class LobbyPlayerControl : MonoBehaviour, IDragHandler
{
    [SerializeField] GameObject lobbyPlayer;
    [SerializeField] GameObject[] lobbyPlayerTypes = new GameObject[(int)CharacterType.Max];
    [SerializeField] float rotateSpeed = 10f;
    Vector3 rot;
    void Start()
    {
        rot = lobbyPlayer.transform.localEulerAngles;
    }
    public void OnDrag(PointerEventData eventData)
    {
        rot.y += eventData.delta.x * rotateSpeed * Time.deltaTime;
        lobbyPlayer.transform.localEulerAngles = -rot;
    }
    public void ChangePlayer(int type)
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        for(int i = 0; i < (int)CharacterType.Max; i++)
        {
            if(i == type)
            {
                lobbyPlayerTypes[i].SetActive(true);
            }
            else
            {
                lobbyPlayerTypes[i].SetActive(false);
            }
        }
    }
}
