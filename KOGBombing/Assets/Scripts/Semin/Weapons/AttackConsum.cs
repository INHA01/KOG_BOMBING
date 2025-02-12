using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Semin
{
	public abstract class AttackConsum : MonoBehaviour, IConsumable
	{
        [SerializeField] protected ParticleSystem particle;
        protected SphereCollider attackCollider;
        public abstract float Damage { get; }
		protected ETeam team;
        public ETeam Team { get { return team; } }
		public WeaponType type;

        public abstract void Use();

		public virtual void SetTeam(int team)
		{
			this.team = (ETeam)team;
            Debug.Log($"team: {team}");
        }

        protected bool IsOtherTeam(PhotonView pView)
        {
            ETeam otherTeam = (ETeam)pView.Owner.CustomProperties["Team"];

            Debug.Log($"otherTeam: {otherTeam}, mine: {team}");
            //customproperties Team 변수를 ETeam타입으로 변경 중
            if (team == otherTeam) return false;
            return true;
        }

        [PunRPC]
        protected void ShowParticle()
        {
            particle.Play();
        }
    }

}
