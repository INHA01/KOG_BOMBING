using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
    public abstract class CompositeNode : Node
    {
        [SerializeField] protected List<Node> children;

        public abstract override INode.ENodeState Evaluate();

        public void AddChild(Node child)
        {
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
    }


}
