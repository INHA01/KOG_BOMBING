using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Realtime;
using Photon.Pun;
public class MasterCheatController : MonoBehaviour
{
    [SerializeField] PhotonView pView;
    void Update()
    {
    }
    [PunRPC]
    private void TransitionPlayerState()
    {
    }

}
