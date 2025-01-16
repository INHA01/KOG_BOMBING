using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public class BehaviorTreeRunner : MonoBehaviour
{
    [SerializeField] public SCBehaviorTree tree;
    [SerializeField] PhotonView pv;
    void Start()
    {
        if (!pv.IsMine) return;
        tree = tree.Clone();
        tree.rootNode.Start();
    }

    void FixedUpdate()
    {
        if (!pv.IsMine) return;
        tree.Operate();
    }
}
