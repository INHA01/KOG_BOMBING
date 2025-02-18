using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static PlayerController;

public class PlayerMovement : PlayerBehavior, IPunObservable
{
    public bool IsNotGroggy()
    {
        return !animator.GetAnimBool(PlayerAnimation.AnimType.Groggy);
    }

    public INode.ENodeState Move()
    {
        Vector3 movement;
		movement = transform.right * blackBoard.playerStatus.moveSpeed * blackBoard.speedValue.x * playerData.speedDebuffPercent;
        movement += transform.forward * blackBoard.playerStatus.moveSpeed * blackBoard.speedValue.y * playerData.speedDebuffPercent;
        movement.y = blackBoard.rigidBody.velocity.y;
        blackBoard.rigidBody.velocity = movement;
        return INode.ENodeState.Success;
    }

    //TODO : Set Camera Target
    public INode.ENodeState RotatePlayer()
    {

        Ray cameraRay = blackBoard.viewCamera.ScreenPointToRay(blackBoard.mousePos);
        RaycastHit hit;
        if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
        {
            Vector3 planePos = hit.point;
            planePos.y += 1.6f;
            Plane GroupPlane = new Plane(Vector3.up, planePos);
            float rayLength;
            if (GroupPlane.Raycast(cameraRay, out rayLength))
            {
                Vector3 pointTolook = cameraRay.GetPoint(rayLength);

                playerData.mousePos = pointTolook;
                playerData.animator.Rotation(pointTolook, blackBoard.speedValue);
                playerData.playerObj.transform.LookAt(pointTolook);
            }
        }

        return INode.ENodeState.Success;
    }

    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
        if (stream.IsWriting)
        {
            stream.SendNext(transform.rotation);
            stream.SendNext(blackBoard.rigidBody.velocity);
        }
        else if (stream.IsReading)
        {
            transform.rotation = (Quaternion)stream.ReceiveNext();
            blackBoard.rigidBody.velocity = (Vector3)stream.ReceiveNext();
            
            float lag = Mathf.Abs((float)(PhotonNetwork.Time - info.SentServerTime));
            transform.position += blackBoard.rigidBody.velocity * lag;
        }
    }
}
