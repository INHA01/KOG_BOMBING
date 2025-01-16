using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
    public abstract class CompositeNode : Node
    {
        [SerializeField] protected List<Node> children = new List<Node>();

        public abstract override INode.ENodeState Evaluate();

        public override void Start()
        {
			for (int i = 0; i < children.Count; i++) 
                children[i].Start();
        }

        public void AddChild(Node child)
        {
            if (children == null)
                children = new List<Node>();
            children.Add(child);
        }

        public void RemoveChild(Node child)
        {
            children.Remove(child);
        }

        public List<Node> GetChild()
        {
            return children;
        }

        public override Node Clone()
        {
            CompositeNode node = Instantiate(this);
            node.children = children.ConvertAll(c => c.Clone());
            return node;
		}
		public override void SetTarget(GameObject target)
		{
            base.SetTarget(target);
			for ( int i = 0; i < children.Count; i++ )
            {
                children[i].SetTarget(target);
			}
		}
	}


}
