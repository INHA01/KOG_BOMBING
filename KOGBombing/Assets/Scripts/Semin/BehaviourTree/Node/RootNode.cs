using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public class RootNode : Node
	{
		public Node child;

		public RootNode(Node node)
		{
			child = node;
		}

		public override INode.ENodeState Evaluate()
		{
			return child.Evaluate();
		}

		public override Node Clone()
		{
			RootNode node = Instantiate(this);
			node.child = child.Clone();
			return node;
		}

        public override void Start()
        {
			child.Start();
        }
    }
}