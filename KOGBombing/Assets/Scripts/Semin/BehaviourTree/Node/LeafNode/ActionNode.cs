using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Reflection;

namespace Semin
{
	public class ActionNode : Node
    {

        public Func<INode.ENodeState> act;
        [HideInInspector] public PlayerController target;
        public string paramName = null;
        public System.Type paramType = null;

        public PlayerController targetInspector { get { return target; } }
        public string method = "";


        public ActionNode(Func<INode.ENodeState> onUpdate)
        {
            act = onUpdate;
        }

        public void SetAction(string methodName, PlayerController controller)
        {
            method = methodName;
            target = controller;
            paramType = null;
            paramName = null;
        }

        public void SetActionWithParam(string methodName, PlayerController controller, System.Type paramType, string paramName)
        {
            method = methodName;
            target = controller;
            this.paramType = paramType;
            Debug.Log(this.paramType);
            this.paramName = paramName;
        }

        public override void Start()
        {
            var methdoInfo = target.GetType().GetMethod(method);
            if (methdoInfo != null)
            {
                if (paramName != null)
                {
                    ParameterInfo[] parameters = methdoInfo.GetParameters();
                    System.Type type = parameters[0].ParameterType;
                    act = () => (INode.ENodeState)methdoInfo.Invoke(target, new object[] { Enum.Parse(type, paramName) });
                }
                else
                {
                    act = (Func<INode.ENodeState>)Delegate.CreateDelegate(typeof(Func<INode.ENodeState>), target, methdoInfo);
                }
            }
        }

        public override INode.ENodeState Evaluate()
        {
            if (act != null)
                act.Invoke();
            return INode.ENodeState.Fail;
        }
    }
}
