using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BehaviorTreeRunner : MonoBehaviour
{
    [SerializeField] public SCBehaviorTree tree;
    void Start()
    {
        tree = tree.Clone();
        tree.rootNode.Start();
    }

    void FixedUpdate()
    {
        tree.Operate();
    }
}
