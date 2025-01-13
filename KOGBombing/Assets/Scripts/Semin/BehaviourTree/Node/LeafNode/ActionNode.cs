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
        [SerializeField] public string paramName = null;
        [SerializeField] public string method = "";


        public ActionNode(Func<INode.ENodeState> onUpdate)
        {
            act = onUpdate;
        }

        public void SetAction(string methodName, PlayerController controller)
        {
            method = methodName;
            target = controller;
            paramName = null;
        }

        public void SetActionWithParam(string methodName, PlayerController controller, string paramName)
        {
            method = methodName;
            target = controller;
            this.paramName = paramName;
        }

        public override void Start()
        {
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
                return act.Invoke();
            return INode.ENodeState.Fail;
        }
    }
}
