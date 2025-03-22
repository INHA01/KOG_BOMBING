using UnityEngine;
using BAEK;
using System.Collections;
using Photon.Pun;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using DG.Tweening.Core.Easing;
namespace Orpul1
{
    public class PlayerHealthUpdater : MonoBehaviour
    {
        [SerializeField] PlayerBlackBoard blackBoard;
        [SerializeField] PlayerAnimation playerAnimation;
        [SerializeField] PlayerData playerData;
        Coroutine groggyCoroutine;
        float groggyTime = 0;
        public void Damage(float damage, int playerIndex)
        {

            DecreaseHp(blackBoard, damage);
            if (blackBoard.playerStatus.hp <= 0)
            {
                if (blackBoard.playerStatus.groggyable)
                {
                    DoGroggyState(blackBoard);
                }
                else if (blackBoard.playerStatus.groggyValue <= 0)
                {
                    blackBoard.playerStatus.groggyValue = 0;
                    blackBoard.hpBar.SetGroggyValue(0);
                    Death();
                }
            }
            SetHpbar();
        }
        private void DecreaseHp(PlayerBlackBoard blackBoard, float damage)
        {
            float decreaseHp = blackBoard.playerStatus.defence - damage;
            blackBoard.playerStatus.defence = Mathf.Max(decreaseHp, 0);
            if (decreaseHp < 0)
            {
                float decreaseGroggy = blackBoard.playerStatus.hp + decreaseHp;
                blackBoard.playerStatus.hp = Mathf.Max(decreaseGroggy, 0);
                if (decreaseGroggy < 0)
                    blackBoard.playerStatus.groggyValue += decreaseGroggy;
            }
            blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
            blackBoard.hpBar.SetGroggyValue(blackBoard.playerStatus.groggyValue);

        }
        private void DoGroggyState(PlayerBlackBoard blackBoard)
        {
            if (!blackBoard.playerStatus.isLive)
            {
                blackBoard.playerStatus.groggyable = false;
                blackBoard.hpBar.SetGroggyValue(0);
                Death();
                return;
            }

            if (blackBoard.inputs[EKey.NUM_2])
            {
                if (blackBoard.bombInteraction.GetBomb() != null)
                    blackBoard.bombInteraction.SetBombInteraction(false);
            }

            blackBoard.playerStatus.isGroggy = true;
            blackBoard.playerStatus.groggyable = false;
            blackBoard.speedDebuff.groggyValue = 0.1f;

            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, false);
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Granade, false);
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, true);
            if (playerData.skill is ThrowableSkill skill)
                skill.Disable();
            playerData.supportWeapon.Disable();

            playerAnimation.ChangeWeapon(playerData,((int)WeaponType.NONE));
            blackBoard.hpBar.ShowGroggy();
            blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
            groggyCoroutine = StartCoroutine(Groggy());
        }
        private void Death()
        {
            ShowCursor showCursor = Managers.UI.GetPopupUI<ShowCursor>(UIKEY.Play);
            int soundIndex = (int)blackBoard.characterType * (int)EHitDeathSound.UNI_DEATH;
            EHitDeathSound deathSound = (EHitDeathSound)soundIndex;
            playerData.playerSound.hitDeathSound.ActiveSound(blackBoard.transform, deathSound);
            if (!playerData.showSoundEffect)
            {
                playerData.showSoundEffect = true;
                showCursor.ShowSoundCursor(blackBoard.transform.position, 3, playerData);
            }
            if (playerData.pv.IsMine)
            {
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.STATE.ToString(), EPlayerState.WAITROUND } });

                blackBoard.hpBar.SetStopHpUI(true);
                blackBoard.playerStatus.isLive = false;
                playerData.pv.RPC("SetActiveState", RpcTarget.All, false);
                //SetActiveState(false);
                if (blackBoard.updateTeamState != null)
                    blackBoard.updateTeamState.UpdateTeamState();
            }
            if (groggyCoroutine != null)
                StopCoroutine(groggyCoroutine);

            blackBoard.Initialize();
            blackBoard.playerStatus.isLive = false;
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, false);
            blackBoard.transform.position = blackBoard.spawnPoint;
        }
        private void SetHpbar()
        {
            blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
            blackBoard.hpBar.SetGroggyValue(blackBoard.playerStatus.groggyValue);
        }
        [PunRPC]
        private void SetActiveState(bool isDie)
        {
            for (int i = 0; i < playerData.changeMaterialMeshs.Count; i++)
                playerData.changeMaterialMeshs[i].SetActive(isDie);

            blackBoard.rigidBody.isKinematic = !isDie;
            blackBoard.playerCollider.enabled = isDie;
        }
        private IEnumerator Groggy()
        {
            blackBoard.playerStatus.invincibility = true;
            yield return new WaitForSeconds(2f);
            blackBoard.playerStatus.invincibility = false;
            groggyTime = 0;
            float time = 1f;
            while (blackBoard.playerStatus.groggyValue > 0)
            {
                if (!blackBoard.playerStatus.isGroggy)
                    break;

                while (playerData.isGroggyInteracting)
                    yield return null;

                groggyTime += Time.deltaTime;
                yield return null;
                if (groggyTime < time)
                    continue;
                Damage(blackBoard.playerStatus.maxGroggy / 10, -1);
                groggyTime = 0;
            }
        }
    }
   
}
