using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public enum EKey
	{
		W,
		A,
		S,
		D,
		MAX
	}

	public class EKeyComparer : IEqualityComparer<EKey>
	{
		bool IEqualityComparer<EKey>.Equals(Semin.EKey x, Semin.EKey y)
		{
			return x == y;
		}

		int IEqualityComparer<EKey>.GetHashCode(EKey obj)
		{
			return (int)obj;
		}
	}
}