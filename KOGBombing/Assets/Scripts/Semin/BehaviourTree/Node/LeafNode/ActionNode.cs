using System;
using System.Reflection;
using UnityEngine;

namespace Semin
{
	public class ActionNode : Node
    {
        private Func<INode.ENodeState> act;
        [SerializeField] public string paramName = null;
        [SerializeField] public string method = "";
		public string className = "";
		private Component methodTarget;

		public ActionNode(Func<INode.ENodeState> onUpdate)
        {
            act = onUpdate;
        }

		public void SetAction(string methodName, GameObject controller, string className)
        {
            method = methodName;
            target = controller;
            paramName = null;
            this.className = className;
        }

        public void SetActionWithParam(string methodName, GameObject controller, string paramName, string className)
        {
            method = methodName;
            target = controller;
            this.paramName = paramName;
			this.className = className;
		}

        public override void Start()
        {
			System.Type componentType = System.Type.GetType(className);

			methodTarget = target.GetComponent(componentType);
			var methdoInfo = methodTarget.GetType().GetMethod(method);

			if (methdoInfo != null)
			{
				ParameterInfo[] parameters = methdoInfo.GetParameters();
				if (parameters.Length > 0)
				{
					System.Type type = parameters[0].ParameterType;
					act = () => (INode.ENodeState)methdoInfo.Invoke(methodTarget, new object[] { Enum.Parse(type, paramName) });
				}
				else
				{
					act = (Func<INode.ENodeState>)Delegate.CreateDelegate(typeof(Func<INode.ENodeState>), methodTarget, methdoInfo);
				}
            }
            state = INode.ENodeState.Fail;
        }

        public override INode.ENodeState Evaluate()
		{
			if (act != null)
                state = act.Invoke();
            else state = INode.ENodeState.Fail;
			return state;
		}
	}
}
