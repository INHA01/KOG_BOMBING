using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public class IfDecoratorNode : DecoratorNode
	{
		private Func<bool> condition;

		public IfDecoratorNode(Func<bool> condition, INode child) : base(child)
		{
			this.condition = condition;
		}

		public override INode.ENodeState Evaluate()
		{
			if (condition == null)
				return INode.ENodeState.Fail;

			if (condition.Invoke())
				return child.Evaluate();

			return INode.ENodeState.Fail;
		}
	}

}
