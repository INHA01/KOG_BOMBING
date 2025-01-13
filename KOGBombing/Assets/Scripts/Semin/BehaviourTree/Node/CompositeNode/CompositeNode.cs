using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
    public abstract class CompositeNode : INode
    {
        protected List<INode> children;

        public abstract INode.ENodeState Evaluate();

        public void AddChild(INode child)
        {
            children.Add(child);
        }

        public void RemoveChild(INode child)
        {
            children.Remove(child);
        }
    }


}
