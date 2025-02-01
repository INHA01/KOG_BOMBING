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
        yield return new WaitForEndOfFrame();
		GameObject[] playerObjects = GameObject.FindGameObjectsWithTag("Player");
		for (int i = 0; i < playerObjects.Length; i++)
		{
			players.Add(playerObjects[i].GetComponent<PlayerController>());
			GameObject hpBar = Instantiate(hpUiPrefab, playerObjects[i].transform.position, Quaternion.identity, transform);
			hpBars.Add(hpBar.GetComponent<HpBar>());
		}
	}

    void Update()
    {
        for (int i = 0; i < players.Count; i++)
        {
            hpBars[i].transform.position = cam.WorldToScreenPoint(players[i].transform.position + new Vector3(0, 2.5f, 0));
        }
    }
}
