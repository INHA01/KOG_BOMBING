using Semin;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Semin
{
    public abstract class DecoratorNode : Node
    {
        [SerializeField] protected Node child;

        public override abstract INode.ENodeState Evaluate();

        public override void Start()
        {
            if (child)
                child.Start();
        }

        public DecoratorNode(Node child)
        {
            this.child = child;
        }

        public void SetChild(Node child)
        {
            this.child = child;
        }

        public Node GetChild()
        {
            return child;
        }

        public override Node Clone()
        {
            DecoratorNode node = Instantiate(this);
            if (child != null) 
                node.child = child.Clone();
            return node;
		}
		public override void SetTarget(GameObject target)
		{
			base.SetTarget(target);
            if (child != null)
			    child.SetTarget(target);
		}
	}

}
