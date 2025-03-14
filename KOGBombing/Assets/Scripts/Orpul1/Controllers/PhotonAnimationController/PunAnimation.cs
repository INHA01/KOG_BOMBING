using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using static PlayerAnimation;

public class PunAnimation : MonoBehaviour
{
    [SerializeField] PhotonView pView;
    [SerializeField] PlayerAnimation playerAnime;

    public void SetAnimationBool(AnimType aniType, bool value)
    {
        pView.RPC("PunBool", RpcTarget.All, aniType, value);
    }
    public void SetAnimationTrigger(AnimType aniType)
    {
        pView.RPC("PunTrig", RpcTarget.All, aniType);
    }
    public void ResetAnimTrigger(AnimType aniType)
    {
        pView.RPC("PunResetTrig", RpcTarget.All, aniType);
    }
    public void Shoot()
    {
        pView.RPC("PunShoot", RpcTarget.All);
    }
    [PunRPC]
    private void PunBool(AnimType aniType, bool value)
    {
        playerAnime.SetAnimBool(aniType, value);
    }
    [PunRPC]
    private void PunTrig(AnimType aniType)
    {
        playerAnime.SetAnimTrigger(aniType);
    }
    [PunRPC]
    private void PunResetTrig(AnimType aniType)
    {
        playerAnime.ResetAnimTrigger(aniType);
    }
    [PunRPC]
    private void PunShoot()
    {
        playerAnime.Shoot();
    }

}
