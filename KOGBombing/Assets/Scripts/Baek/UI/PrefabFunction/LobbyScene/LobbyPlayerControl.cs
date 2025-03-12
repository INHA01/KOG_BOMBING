using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using Semin;

public class LobbyPlayerControl : MonoBehaviour, IDragHandler
{
    [SerializeField] GameObject lobbyPlayer;
    [SerializeField] GameObject[] lobbPlayerTypes = new GameObject[(int)CharacterType.Max];
    [SerializeField] float rotateSpeed = 10f;
    Vector3 rot;
    void Start()
    {
        //lobbyPlayer = Managers.Resource.Instantiate("PlayerPrefabs/LobbyNed");
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
                lobbPlayerTypes[i].SetActive(true);
            }
            else
            {
                lobbPlayerTypes[i].SetActive(false);
            }
        }
    }
}
