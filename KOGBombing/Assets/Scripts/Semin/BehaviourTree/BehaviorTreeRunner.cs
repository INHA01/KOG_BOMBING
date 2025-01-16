using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public class BehaviorTreeRunner : MonoBehaviour
{
    [SerializeField] public SCBehaviorTree tree;
    [SerializeField] PhotonView pv;
    [SerializeField] bool canConnectPhoton;
    void Start()
    {
        if (canConnectPhoton&&!pv.IsMine) return;
        tree = tree.Clone();
        tree.rootNode.Start();
    }

    void FixedUpdate()
    {
        if (canConnectPhoton&&!pv.IsMine) return;
        tree.Operate();
    }
}
