using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Animations;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

namespace Semin
{
	public class IfDecoratorNode : DecoratorNode
	{
		private Func<bool> condition;

		public IfDecoratorNode(Func<bool> condition, Node child) : base(child)
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
