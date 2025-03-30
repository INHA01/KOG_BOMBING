using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public abstract class Node : ScriptableObject, INode
	{
        public string guid;
		[HideInInspector] public Vector2 position;
		protected GameObject target;
		public INode.ENodeState state;
		[TextArea] public string description;

		public abstract INode.ENodeState Evaluate();

		public virtual Node Clone()
		{
			return Instantiate(this);
		}

		public virtual void SetTarget(GameObject target)
		{
			this.target = target;
		}

		public abstract void Start();
	}
}