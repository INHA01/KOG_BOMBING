using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public enum CharacterType
	{
		Ned,
		Uni,
		Max
	}


	[CreateAssetMenu(fileName = "Player Data", menuName = "Scriptable Object/Player Data", order = int.MaxValue)]
	public class PlayerDataAsset : ScriptableObject
	{
		[SerializeField] private CharacterType type;
		[SerializeField] private float hp;
		[SerializeField] private float defenceAmount;
		[SerializeField] private float moveSpeed;
		[SerializeField] private float groggyMoveSpeed;

		public CharacterType CharacterType { get { return type; } }
		public float Hp { get { return hp; } }
		public float DefenceAmount { get { return defenceAmount; } }
		public float MoveSpeed { get { return moveSpeed; } }
		public float GroggyMoveSpeed { get { return groggyMoveSpeed; } }
	}

}
