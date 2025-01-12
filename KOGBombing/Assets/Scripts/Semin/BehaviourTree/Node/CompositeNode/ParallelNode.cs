using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.FullSerializer;
using UnityEditor.SearchService;
using UnityEngine;

namespace Semin
{
	public class ParallelNode : CompositeNode
    {
		bool isSuccessed;
		bool isRunning;

		public ParallelNode(List<Node> child)
		{
            children = child;
			isSuccessed = false;
		}

		public override INode.ENodeState Evaluate()
		{
			if (children == null || children.Count == 0)
				return INode.ENodeState.Fail;

			isSuccessed = false;
			isRunning = false; 

			for (int i = 0; i < children.Count; i++)
			{
				switch (children[i].Evaluate())
				{
					case INode.ENodeState.Success:
						isSuccessed = true;
						continue;
					case INode.ENodeState.Running:
						isRunning = true;
						continue;
					case INode.ENodeState.Fail:
						continue;
				}
			}

			if (!isSuccessed)
				return INode.ENodeState.Fail;
			if (isRunning)
				return INode.ENodeState.Running;
			return INode.ENodeState.Success;
		}
	}
		
}
