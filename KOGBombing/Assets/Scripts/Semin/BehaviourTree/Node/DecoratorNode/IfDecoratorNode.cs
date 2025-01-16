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
        public string paramName = "";
		public string className = "";
		private Component methodTarget;

		public IfDecoratorNode(Func<bool> condition, Node child) : base(child)
		{
			this.condition = condition;
        }

        public void SetCondition(string methodName, GameObject controller, string className)
        {
            method = methodName;
            target = controller;
            paramName = null;
            this.className = className;
        }

        public void SetConditionWithParam(string methodName, GameObject controller, string paramName, string className)
        {
            method = methodName;
            target = controller;
            this.paramName = paramName;
            this.className = className;
        }

		public override void SetTarget(GameObject target)
		{
			base.SetTarget(target); 
			child.SetTarget(target);
		}

		public override void Start()
        {
			base.Start();
			System.Type componentType = System.Type.GetType(className);

			methodTarget = target.GetComponent(componentType);

			var methdoInfo = methodTarget.GetType().GetMethod(method);
			if (methdoInfo != null)
			{
				ParameterInfo[] parameters = methdoInfo.GetParameters();
				if (parameters.Length > 0)
				{
					System.Type type = parameters[0].ParameterType;
					condition = () => (bool)methdoInfo.Invoke(methodTarget, new object[] { Enum.Parse(type, paramName) });
				}
				else
				{
					condition = (Func<bool>)Delegate.CreateDelegate(typeof(Func<bool>), methodTarget, methdoInfo);
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
