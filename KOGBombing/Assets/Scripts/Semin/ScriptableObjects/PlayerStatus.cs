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
	public class PlayerStatus : ScriptableObject
	{
		[SerializeField] private CharacterType type;
        public float hp;
        public float maxHp;
        public float moveSpeed;
        public float defence;
        public float maxDefence;
        public float reviveInterval;
        public float groggyValue;
        public float maxGroggy;
        public bool isLive;
        public bool isGroggy;
        public bool groggyable;
        public bool isBombInteract;
        public bool isBombDefuse;
        public bool invincibility;
        public bool canSettingBomb;
		public CharacterType CharacterType { get { return type; } }
	}

}
