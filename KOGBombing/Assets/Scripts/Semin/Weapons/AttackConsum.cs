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
		protected string team;
		public WeaponType type;

        public abstract void Use();

		public virtual void SetTeam(string team)
		{
			this.team = team;
            Debug.Log($"team: {team}");
        }

        protected bool IsOtherTeam(PhotonView pView)
        {
            string otherTeam = (string)pView.Owner.CustomProperties["Team"];

            Debug.Log($"otherTeam: {otherTeam}, mine: {team}");

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
