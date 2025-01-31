using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Knife.Effects.SimpleController
{
    /// <summary>
    /// RPG Weapon component.
    /// </summary>
    public class RPG : Weapon
    {
        /// <summary>
        /// Projectile spawn point.
        /// </summary>
        [SerializeField] [Tooltip("Projectile spawn point")] private Transform rpgProjectileSpawnPoint;
        /// <summary>
        /// Projectile prefab.
        /// </summary>
        [SerializeField] [Tooltip("Projectile prefab")] private GameObject rpgProjectilePrefab;
        /// <summary>
        /// Player root transform.
        /// </summary>
        [SerializeField] [Tooltip("Player root transform")] private GameObject rpgPlayerRoot;

        private Collider[] playerColliders;

        protected override void OnEnableHook()
        {
            playerColliders = rpgPlayerRoot.GetComponents<Collider>();
        }

        protected override void Shot()
        {
            PlayFX();
            handsAnimator.Play("Shot", 0, 0);
            var instance = Instantiate(rpgProjectilePrefab, rpgProjectileSpawnPoint.position, rpgProjectileSpawnPoint.rotation);
            var ignoreCollision = instance.GetComponent<ICollisionIgnore>();
            if (ignoreCollision != null)
            {
                foreach (var c in playerColliders)
                {
                    ignoreCollision.IgnoreCollision(c);
                }
            }
            Destroy(instance, 30);
        }
    }
}