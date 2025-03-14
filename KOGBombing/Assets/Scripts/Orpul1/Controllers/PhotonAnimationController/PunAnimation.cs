using System.Collections;
using System.Collections.Generic;
using DG.Tweening.Core.Easing;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using static PlayerAnimation;
using static UnityEngine.Rendering.DebugUI;

public class PunAnimation : MonoBehaviour
{
    enum ERotateAniType
    {
        Rotation,
        IsMoving,
        END,
    }
    [SerializeField] PhotonView pView;
    [SerializeField] PlayerAnimation playerAnime;
    [SerializeField] Animator animator;
    [SerializeField] Transform rotatePlayer;

    public void SetAnimationBool(AnimType aniType, bool value)
    {
        pView.RPC("PunBool", RpcTarget.All, aniType, value);
    }
    public void SetAnimationTrigger(AnimType aniType, Vector3 pointLookAt)
    {
        pView.RPC("PunTrig", RpcTarget.All, aniType, pointLookAt);
    }
    public void ResetAnimTrigger(AnimType aniType)
    {
        pView.RPC("PunResetTrig", RpcTarget.All, aniType);
    }
    public void Shoot(Vector3 pointLookAt)
    {
        pView.RPC("PunShoot", RpcTarget.All, pointLookAt);
    }

    public void Rotation(Vector3 pointToLookAt, Vector3 speedValue)
    {
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(1);
        if (stateInfo.IsName(AnimType.Throw.ToString()))
            return;
        playerAnime.SetPointToLookAt(pointToLookAt);
        Vector3 direction = pointToLookAt - rotatePlayer.position;
        direction.y = 0;
        float angle = Vector3.SignedAngle(rotatePlayer.forward, direction, Vector3.up);

        if (speedValue.magnitude < 0.1f)
        {

            SetAnimationBool(AnimType.IsMoving, false);
            float deltaAngle = Mathf.Abs(angle);
            if (deltaAngle < 0.5f)
                animator.SetBool(ERotateAniType.Rotation.ToString(), false);
            else if (deltaAngle >= 60.0f)
            {
                animator.SetBool(ERotateAniType.IsMoving.ToString(), true);
                animator.SetBool(ERotateAniType.Rotation.ToString(), true);
            }
            if (animator.GetBool(AnimType.Rotation.ToString()) == true)
            {
                Quaternion targetRotation = Quaternion.LookRotation(direction);
                rotatePlayer.rotation = Quaternion.Slerp(rotatePlayer.rotation, targetRotation, playerAnime.RotateSpeed * Time.deltaTime);
                if (angle > 0)
                {
                    SetAnimationBool(AnimType.Right, true);
                    SetAnimationBool(AnimType.Left, false);
                }
                else
                {
                    SetAnimationBool(AnimType.Right, false);
                    SetAnimationBool(AnimType.Left, true);
                }

            }
        }
        else
        {
            animator.SetBool(ERotateAniType.IsMoving.ToString(), false);
            animator.SetBool(ERotateAniType.Rotation.ToString(), false);
            Quaternion targetRotation = Quaternion.LookRotation(direction);
            rotatePlayer.rotation = Quaternion.Slerp(rotatePlayer.rotation, targetRotation, playerAnime.RotateSpeed * Time.deltaTime);
        }
    }

    [PunRPC]
    private void PunRotate(ERotateAniType aniType, bool value)
    {
        animator.SetBool(aniType.ToString(), value);
    }
    [PunRPC]
    private void PunBool(AnimType aniType, bool value)
    {
        playerAnime.SetAnimBool(aniType, value);
    }
    [PunRPC]
    private void PunTrig(AnimType aniType,Vector3 pointLookAt)
    {
        playerAnime.SetAnimTrigger(aniType, pointLookAt);
    }
    [PunRPC]
    private void PunResetTrig(AnimType aniType)
    {
        playerAnime.ResetAnimTrigger(aniType);
    }
    [PunRPC]
    private void PunShoot(Vector3 pointLookAt)
    {
        playerAnime.Shoot(pointLookAt);
    }
}
