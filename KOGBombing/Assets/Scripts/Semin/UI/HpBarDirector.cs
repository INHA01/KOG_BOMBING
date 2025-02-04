using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HpBarDirector : MonoBehaviour
{
    [SerializeField] GameObject hpUiPrefab;
    [SerializeField] List<HpBar> hpBars = new List<HpBar>();
    [SerializeField] List<PlayerController> players = new List<PlayerController>();
    [SerializeField] Camera cam;

    void Start()
    {
        StartCoroutine(ReadyToStart());
    }

    public void SetCamera(Camera cam)
    {
        this.cam = cam;
    }

    IEnumerator ReadyToStart()
    {
        yield return new WaitForFixedUpdate();

        Player[] playersTemp = PhotonNetwork.PlayerList;
		for (int i = 0; i < playersTemp.Length; i++)
        {
            PhotonView photonView = PhotonView.Find(playersTemp[i].ActorNumber);
            if (photonView != null)
            {
                GameObject playerObject = photonView.gameObject;
                players.Add(playerObject.GetComponent<PlayerController>());
                GameObject hpBar = Instantiate(hpUiPrefab, playerObject.transform.position, Quaternion.identity, transform);
                hpBars.Add(hpBar.GetComponent<HpBar>());
            }

		}
        Debug.Log($"플레이어 수 : {playersTemp.Length}");

    }

    void Update()
    {

        // 모든 플레이어를 순회
        Player[] playersTemp = PhotonNetwork.PlayerList;
		for (int i = 0; i < playersTemp.Length; i++)
        {
            PhotonView photonView = PhotonView.Find(playersTemp[i].ActorNumber);
            if (photonView != null)
            {
                GameObject playerObject = photonView.gameObject;
                hpBars[i].transform.position = cam.WorldToScreenPoint(playerObject.transform.position + new Vector3(0, 2.5f, 0));
            }
		}
    }
}
