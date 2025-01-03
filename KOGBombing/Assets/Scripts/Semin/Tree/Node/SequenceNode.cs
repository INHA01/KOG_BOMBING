using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

namespace Semin
{
	public class SequenceNode : INode
	{
		List<INode> child;

		public SequenceNode(List<INode> node)
		{
			child = node;
		}

		public INode.ENodeState Evaluate()
		{
			if (child == null || child.Count == 0)
				return INode.ENodeState.Fail;

			for (int i = 0; i < child.Count; i++)
			{
				switch (child[i].Evaluate())
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
