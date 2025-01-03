using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Semin
{
	public class ActionNode : INode
	{
		Func<INode.ENodeState> update = null;

		public INode.ENodeState Evaluate()
		{
			if (update != null)
				return update.Invoke();
			else return INode.ENodeState.Fail;
		}
	}
}
