using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Semin
{
	public class ActionNode : INode
	{
		Func<INode.ENodeState> act = null;

		public INode.ENodeState Evaluate()
		{
			if (act != null)
				return act.Invoke();
			else return INode.ENodeState.Fail;
		}
	}
}
