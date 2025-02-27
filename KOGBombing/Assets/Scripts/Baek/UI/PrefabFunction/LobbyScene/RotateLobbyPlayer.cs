using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class RotateLobbyPlayer : MonoBehaviour, IDragHandler
{
    [SerializeField] GameObject lobbyPlayer;
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

}
