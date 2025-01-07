using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

namespace Semin
{
	public class SequenceNode : INode
	{
		List<INode> children;

		public SequenceNode(List<INode> node)
		{
			children = node;
		}

		public INode.ENodeState Evaluate()
		{
			if (children == null || children.Count == 0)
				return INode.ENodeState.Fail;

			for (int i = 0; i < children.Count; i++)
			{
				switch (children[i].Evaluate())
				{
					case INode.ENodeState.Running:
						return INode.ENodeState.Running;
					case INode.ENodeState.Success:
						continue;
					case INode.ENodeState.Fail:
						return INode.ENodeState.Fail;
				}
			}

			return INode.ENodeState.Success;
		}
	}
}
