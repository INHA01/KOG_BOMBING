using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EKey
{
	W,
	A,
	S,
	D,
	F,
	LMOUSEBUTTON,
	NUM_2,
    Escape,
    MAX
}

public class EKeyComparer : IEqualityComparer<EKey>
{
	bool IEqualityComparer<EKey>.Equals(EKey x, EKey y)
	{
		return x == y;
	}

	int IEqualityComparer<EKey>.GetHashCode(EKey obj)
	{
		return (int)obj;
	}
}