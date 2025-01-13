using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public class BehaviourTree
	{
		INode rootNode;

		public BehaviourTree(INode node)
		{
			rootNode = node;
		}

		public void Operate()
		{
			rootNode.Evaluate();
		}
	}

}