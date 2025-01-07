using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.FullSerializer;
using UnityEditor.SearchService;
using UnityEngine;

namespace Semin
{
	public class ParallelNode : INode
	{
		List<INode> child;
		bool isSuccessed;
		bool isRunning;

		public ParallelNode(List<INode> child)
		{
			this.child = child;
			isSuccessed = false;
		}

		public INode.ENodeState Evaluate()
		{
			if (child == null || child.Count == 0)
				return INode.ENodeState.Fail;

			isSuccessed = false;
			isRunning = false; 

			for (int i = 0; i < child.Count; i++)
			{
				switch (child[i].Evaluate())
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
