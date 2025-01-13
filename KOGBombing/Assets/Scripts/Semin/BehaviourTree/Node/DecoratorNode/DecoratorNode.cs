using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
    public abstract class DecoratorNode : INode
    {
        protected INode child;

        public abstract INode.ENodeState Evaluate();

        public DecoratorNode(INode child)
        {
            this.child = child;
        }
    }

}
