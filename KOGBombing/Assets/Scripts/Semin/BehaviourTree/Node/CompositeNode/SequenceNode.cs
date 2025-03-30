using System.Collections;
using System.Collections.Generic;
using System.Resources;
using UnityEngine;
using UnityEngine.UIElements;

namespace Semin
{
	public class SequenceNode : CompositeNode
    {
		public SequenceNode(List<Node> node)
		{
			children = node;
		}

		public override INode.ENodeState Evaluate()
		{
			if (children == null || children.Count == 0)
			{
				state = INode.ENodeState.Fail;
				return state;
			}

			for (int i = 0; i < children.Count; i++)
            {
                switch (children[i].Evaluate())
				{
					case INode.ENodeState.Running:
						state = INode.ENodeState.Running;
                        return INode.ENodeState.Running;
					case INode.ENodeState.Success:
						continue;
					case INode.ENodeState.Fail:
						state = INode.ENodeState.Fail;
						for (int j = i; j < children.Count; j++)
							children[j].state = INode.ENodeState.Fail;
						return INode.ENodeState.Fail;
				}
			}

			state = INode.ENodeState.Success;
			return INode.ENodeState.Success;
		}
	}
}
