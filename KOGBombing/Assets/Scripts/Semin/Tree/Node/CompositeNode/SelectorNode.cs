using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public class SelectorNode : INode
	{
		List<INode> children;

		public SelectorNode(List<INode> chlid)
		{
			children = chlid;
		}

		public INode.ENodeState Evaluate()
		{
			if (children == null)
				return INode.ENodeState.Fail;

			for (int i = 0; i < children.Count; i++)
			{
				switch (children[i].Evaluate())
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