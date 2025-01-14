using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

namespace Semin
{
	public class IfDecoratorNode : DecoratorNode
	{
		private Func<bool> condition;
        public string method = "";
        [HideInInspector] public PlayerController target;
        public string paramName = "";

		public IfDecoratorNode(Func<bool> condition, Node child) : base(child)
		{
			this.condition = condition;
        }

        public void SetCondition(string methodName, PlayerController controller)
        {
            method = methodName;
            target = controller;
            paramName = null;
        }

        public void SetConditionWithParam(string methodName, PlayerController controller, string paramName)
        {
            method = methodName;
            target = controller;
            this.paramName = paramName;
        }

        public override void Start()
        {
            base.Start();
            if (target == null)
            {
                target = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
            }
            var methdoInfo = target.GetType().GetMethod(method);
            if (methdoInfo != null)
            {
                ParameterInfo[] parameters = methdoInfo.GetParameters();
                if (parameters.Length > 0)
                {
                    System.Type type = parameters[0].ParameterType;
                    condition = () => (bool)methdoInfo.Invoke(target, new object[] { Enum.Parse(type, paramName) });
                }
                else
                {
                    condition = (Func<bool>)Delegate.CreateDelegate(typeof(Func<bool>), target, methdoInfo);
                }
            }
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
