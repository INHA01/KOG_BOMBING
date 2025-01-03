using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public interface INode
	{
		public enum ENodeState
		{
			Success,
			Fail,
			Running
		}

		public ENodeState Evaluate();
	}

}
