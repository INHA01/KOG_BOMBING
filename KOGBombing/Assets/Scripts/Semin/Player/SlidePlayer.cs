using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using Cinemachine;
using UnityEngine;

public class SlidePlayer : MonoBehaviour
{
    [SerializeField] PlayerBlackBoard blackBoard;
    List<Vector3> slideDir = new List<Vector3>();
    List<Vector3> contactPosi = new List<Vector3>();
    private void OnCollisionStay(Collision collision)
    {
        Debug.Log($"contactCount {collision.contactCount}");
        if(collision.contactCount<=1)
        {
            slideDir.Clear();
            return;
        }
        
        for (int i=1; i<collision.contactCount; i++)
        {
            Vector3 moveDir = new Vector3(blackBoard.speedValue.x, 0, blackBoard.speedValue.y);
            Vector3 slideMove = Vector3.ProjectOnPlane(moveDir, collision.contacts[i].normal);
            Vector2 velocity = new Vector2(slideMove.x, slideMove.z);
            blackBoard.rigidBody.velocity = velocity;
            contactPosi.Add(collision.contacts[i].point);
            slideDir.Add(velocity);
            Debug.Log($"position {transform.position} normal {collision.contacts[i].normal}");
        }
        
        Debug.Log("Sliding");
    }
    private void OnDrawGizmos()
    {
        if (contactPosi.Count == 0 || slideDir.Count == 0) return;
        for (int i = 0; i < slideDir.Count; i++) 
        {
            Gizmos.DrawLine(contactPosi[i], contactPosi[i] + slideDir[i]);
        }
    }
}
