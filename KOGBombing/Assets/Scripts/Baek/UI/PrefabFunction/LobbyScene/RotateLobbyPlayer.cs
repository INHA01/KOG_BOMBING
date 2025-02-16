using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class RotateLobbyPlayer : MonoBehaviour  ,IBeginDragHandler , IEndDragHandler, IDragHandler
{
    [SerializeField] GameObject lobbyPlayer;
    float rotateSpeed = 10f;
    Vector3 rot;
    bool isSpin = false;
    Vector2 dragStartPos;
    Vector2 dragEndPos;
    void Start()
    {
        //lobbyPlayer = Managers.Resource.Instantiate("PlayerPrefabs/LobbyNed");
        rot = lobbyPlayer.transform.localEulerAngles;
    }
    void Update()
    {
        if (isSpin)
        {
            rot.y += rotateSpeed * Time.deltaTime;
            lobbyPlayer.transform.localEulerAngles = -rot;
            rotateSpeed *= 0.99f;
            rotateSpeed = rotateSpeed < 0.01f ? 0 : rotateSpeed;
        }
    }
    public void OnDrag(PointerEventData eventData)
    {
        rot.y += eventData.delta.x * 10 * Time.deltaTime;
        lobbyPlayer.transform.localEulerAngles = -rot;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        isSpin = false;
        dragStartPos = eventData.position;
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        dragEndPos = eventData.position;
        rotateSpeed = (dragEndPos.x - dragStartPos.x) * 30;
        isSpin = true;
    }
}
