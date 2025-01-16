using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Semin;
using UnityEngine;

public class BehaviorTreeRunner : MonoBehaviour
{
    [SerializeField] public SCBehaviorTree tree;
    [SerializeField] PhotonView pv;
    [SerializeField] bool canConnectPhoton;

    void Start()
    {
        if (canConnectPhoton&&!pv.IsMine) return;
        tree.SetTarget(gameObject);
		//tree.rootNode.Start();
		//tree = tree.Clone();
    }

	private void LateUpdate()
	{
		if (canConnectPhoton && !pv.IsMine) return;
		tree.Operate();
	}
}
