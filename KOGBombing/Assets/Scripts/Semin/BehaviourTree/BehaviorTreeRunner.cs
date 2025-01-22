using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Semin;
using Unity.VisualScripting;
using UnityEngine;

public class BehaviorTreeRunner : MonoBehaviour
{
    [SerializeField] public BehaviorTreeAsset tree;
    [SerializeField] PhotonView pv;

    void Start()
    {
        if (!pv.IsMine) return;
		tree = tree.Clone();
		tree.SetTarget(gameObject);
		StartCoroutine(Ready());
    }

	private void FixedUpdate()
	{
		if (!pv.IsMine) return;
		tree.Operate();
	}

    IEnumerator Ready()
    {
        yield return new WaitForEndOfFrame();
        tree.rootNode.Start();
    }
}
