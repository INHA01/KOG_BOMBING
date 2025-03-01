using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BombInteraction : MonoBehaviour
{
    [SerializeField] Bomb bomb;
	[SerializeField] PhotonView pv;

    public void SetBomb(Bomb bomb)
    {
        this.bomb = bomb;
        pv = GetComponent<PhotonView>();
    }

    public void SetBombInteraction(bool isInteraction)
    {
        pv.RPC("RPCSetBombInteraction", RpcTarget.AllBuffered, isInteraction);

	}

    [PunRPC]
    public void RPCSetBombInteraction(bool isInteraction)
    {
		bomb.SetIsInteraction(isInteraction);
	}
}
