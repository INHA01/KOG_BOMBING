using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class DecoraterNode : INode
{
	protected INode child;

	public abstract INode.ENodeState Evaluate();

	public DecoraterNode(INode child)
	{
		this.child = child; 
	}
}
