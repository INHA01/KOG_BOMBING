using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BombInteraction : MonoBehaviour
{
    [SerializeField] Bomb bomb = null;
	[SerializeField] PhotonView pv;

    public void SetBomb(Bomb bomb)
    {
        this.bomb = bomb;
        pv = GetComponent<PhotonView>();
    }

    public Bomb GetBomb()
    {
        return bomb;
    }


    public void SetBombInteraction(bool isInteraction)
    {
        pv.RPC("RPCSetBombInteraction", RpcTarget.AllBuffered, isInteraction);

	}

    public void Initialize()
    {
        bomb.Release();
    }

    [PunRPC]
    public void RPCSetBombInteraction(bool isInteraction)
	{
		if (bomb != null)
        {
		    bomb.SetIsInteraction(isInteraction);
		}
	}
}
