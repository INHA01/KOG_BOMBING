using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public abstract class Node : ScriptableObject, INode
	{
        [HideInInspector] public string guid;
		[HideInInspector] public Vector2 position;

		public abstract INode.ENodeState Evaluate();

		public virtual Node Clone()
		{
			return Instantiate(this);
		}

		public virtual void Start()
		{

		}
	}
}