using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public class SelectorNode : INode
	{
		List<INode> child;

		public SelectorNode(List<INode> chlid)
		{
			child = chlid;
		}

		public INode.ENodeState Evaluate()
		{
			if (child == null)
				return INode.ENodeState.Fail;

			for (int i = 0; i < child.Count; i++)
			{
				switch (child[i].Evaluate())
				{
					case INode.ENodeState.Running:
						return INode.ENodeState.Running;
					case INode.ENodeState.Success:
						return INode.ENodeState.Success;
				}
			}

			return INode.ENodeState.Fail;
		}
	}
}