using UnityEngine;
using BAEK;
using System.Collections;
using Photon.Pun;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using UnityEditor;
using System.Collections.Generic;
using Michsky.UI.Shift;
using Semin;
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
            SetHpbar();
            if (blackBoard.playerStatus.hp > 0) return;

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
            if (!playerData.pv.IsMine) return;
            blackBoard.updateTeamState.UpdateTeamState();
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
            if (!blackBoard.playerStatus.isLive|| !CanGroggy())
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
        /*
        

   private bool CanGroggy()
    {
        GameObject[] players = GameObject.FindGameObjectsWithTag("Player");
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];

      for (int i = 0; i < players.Length; i++)
        {
            if (players[i] == gameObject) continue;
            ETeam otherPlayerTeam = (ETeam)players[i].GetComponent<PlayerData>().pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
            if (myTeam == otherPlayerTeam)  //         ٸ   °      ִ    Ȯ  
            {
                Debug.Log($"MyPlayer: {myTeam}, otherTeam: {otherPlayerTeam}, {players[i].name}");
                if (players[i].GetComponent<PlayerBlackBoard>().playerStatus.isLive)
                    return true;
            }
      }
        return false;
    }
         */

        private bool CanGroggy()
        {
            if (!playerData.pv.IsMine) return true;
            List<PlayerStateData> playerDatas = Managers.PunData.GetAllStateData();
            ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            int mPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            for (int i = 0; i < playerDatas.Count; i++)
            {
                if (mPlayerIndex == playerDatas[i].playerIndex) continue;
                if (playerDatas[i].playerStatus.isLive)
                    return true;
            }
            return false;
        }
        private void Death()
        {
            int soundIndex = (int)playerData.characterType * (int)EHitDeathSound.UNI_DEATH;
            EHitDeathSound deathSound = (EHitDeathSound)soundIndex;
            playerData.playerSound.hitDeathSound.ActiveSound(blackBoard.transform, deathSound);
            if (!playerData.showSoundEffect)
            {
                playerData.showSoundEffect = true;
                playerData.pv.RPC("PunShowCursor", RpcTarget.All);
            }
            if (playerData.pv.IsMine)
            {
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.STATE.ToString(), EPlayerState.WAITROUND } });
                blackBoard.hpBar.SetStopHpUI(true);
                blackBoard.playerStatus.isLive = false;
                playerData.pv.RPC("SetActiveState", RpcTarget.All, false);
                if (blackBoard.updateTeamState != null)
                    blackBoard.updateTeamState.UpdateTeamState();
                StartCoroutine("CoObservePlayer");
            }
            if (groggyCoroutine != null)
                StopCoroutine(groggyCoroutine);

            blackBoard.playerStatus.isLive = false;
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, false);
            blackBoard.transform.position = blackBoard.spawnPoint;
        }
        [PunRPC]
        private void PunShowCursor()
        {
            ShowCursor showCursor = Managers.UI.GetPopupUI<ShowCursor>(UIKEY.Play);
            showCursor.ShowSoundCursor(blackBoard.transform.position, 3, playerData);
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

        IEnumerator CoObservePlayer()
        {
            while(true)
            {
                yield return null;
                if(FindAlivePlayer())
                {
                    SetCameraTarget();
                    break;
                }
            }
            while(true)
            {
                yield return null;
                if (blackBoard.playerStatus.isLive) yield break;
                if (!IsTargetDie()) continue;
                if (!FindAlivePlayer()) continue;
                SetCameraTarget();
            }
        }
        public bool IsTargetDie()
        {
            if (!Managers.PunData.IsContainKey(blackBoard.observaTargetIndex))
                return false;

            bool isLiveTarget = Managers.PunData.GetPlayerStateData(blackBoard.observaTargetIndex).playerStatus.isLive;
            Debug.Log("PlayerDie Search alive Other Player");
            if (isLiveTarget)
                return false;
            Debug.Log("PlayerDie Observe Other Player");
            return true;
        }
        public bool FindAlivePlayer()
        {
            List<PlayerStateData> playerStateList = Managers.PunData.GetAllStateData();
            Debug.Log("Search Alive Player");
            for (int i = 0; i < playerStateList.Count; i++)
            {
                if (playerStateList[i].rigidBody == null) return false;
                if (playerStateList[i].playerTeam != playerData.playerTeam) continue;
                if (playerStateList[i].rigidBody.gameObject == gameObject) continue;
                if (!playerStateList[i].playerStatus.isLive) continue;

                Debug.Log($"Find Target {playerStateList[i].nickname}");
                blackBoard.observaTarget = playerStateList[i].observaTarget;
                blackBoard.observaTargetIndex = playerStateList[i].playerIndex;
                return true;
            }
            blackBoard.observaTarget = null;
            return false;
        }
        public void SetCameraTarget()
        {

            if (Managers.PunData.GetPlayerStateData(blackBoard.observaTargetIndex).playerStatus.isLive)
            {
                blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(blackBoard.observaTarget);
                blackBoard.viewCamera.transform.LookAt(blackBoard.observaTarget.transform);
                Debug.Log("Set Camera Look Alive Player");
                return;
            }
            blackBoard.observaTarget = null;
            return;
        }
    }
   
}
