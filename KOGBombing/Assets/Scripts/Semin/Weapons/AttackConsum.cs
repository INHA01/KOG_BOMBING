using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Semin
{
	public abstract class AttackConsum : PooledObject, IConsumable
	{
        [SerializeField] protected ParticleSystem particle;
        protected SphereCollider attackCollider;
        public abstract float Damage { get; }
		protected ETeam team;
        protected int playerIndex;
        public ETeam Team { get { return team; } }
        public int PlayerIndex { get { return playerIndex; } }
		public WeaponType type;
        public bool isActive;
        [SerializeField] protected PlayerData playerData;
        public abstract void Use();

		public virtual void SetTeam(int team, PlayerData playerData)
		{
			this.team = (ETeam)team;
            this.playerData = playerData;
		}
        public virtual void SetPlayerIndex(int playerIndex)
        {
            this.playerIndex = playerIndex; 
        }
        protected bool IsOtherTeam(PhotonView pView)
        {
            ETeam otherTeam = (ETeam)pView.Owner.CustomProperties[EPropertyType.TEAM.ToString()];

            //Debug.Log($"otherTeam: {otherTeam}, mine: {team}");
            //customproperties Team 변수를 ETeam타입으로 변경 중
            if (team == otherTeam) return false;
            return true;
        }

        [PunRPC]
        protected void ShowParticle()
        {
            particle.Play();
			if (playerData.pv.IsMine)
				playerData.pv.RPC("PunPlaySound", RpcTarget.AllBuffered, (int)EWeaponSound.EXPLOSION);
		}

		[PunRPC]
		void PunPlaySound(int type)
		{
			AudioClip effect = playerData.soundList.WeaponList[type];
			SoundManager.Instance.PlayEffect(effect, transform, 1, 0, 50);
		}

	}

}
