using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EBombSound
{
    BEEP,
    EXPLOSION,
}
public struct BombData
{
    public string nickname;
    public IBombStateAble bombState;
}
[Serializable]
public struct BombSound
{
    public List<AudioClip> bombSoundList;
    public float beepSoundInterval;
    public void ActiveSound(Transform transform, int soundType)
    {
        AudioClip bombSound = bombSoundList[soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.EFFECT, transform, 1, 0, 30);
    }
}
public class Bomb : AttackConsum,IDefendencyAble<BombData>,IResetAble
{
    [SerializeField] float bombTime = 20f;
    [SerializeField] BombSound bombSound;
    float time = 0;
    public override float Damage { get { return 0; } }
    Coroutine destroyCoroutine;
    BombNotify bombNotify;
	bool isInteracting = false;
    public bool isUsable = true;
    PhotonView pv;
    BombData bombData;
    RaiseEventOptions options = new RaiseEventOptions();
    int bombEventCode = 50;
    public float BombTime { get { return bombTime; } } 
	private void Awake()
	{
		pv = GetComponent<PhotonView>();
        options.Receivers = ReceiverGroup.All;

    }
    public void Notify()
    {
        // 폭탄 설치 모든 플레이어들에게 Notify
        NotifySet();
    }
    void NotifySet()
    {
        if (bombNotify == null)
            bombNotify = Managers.UI.ShowPopupUI<BombNotify>("BombNotifyCanvas");
        else
            bombNotify.gameObject.SetActive(true);
        if (bombData.bombState != null)
            bombData.bombState.BombEvent(EBombState.SET, -1);
        bombNotify.NotifyBombSet();
    }
    private void OnTriggerStay(Collider other)
    {
        PlayerBlackBoard player = other.GetComponent<PlayerBlackBoard>();
        if (player != null)
        {
            if (bombNotify == null)
                bombNotify = Managers.UI.GetPopupUI<BombNotify>("BombNotifyCanvas");
            if (player.playerStatus.isBombDefuse)
            {
                player.playerStatus.isBombDefuse = false;
                // 폭탄 해제 모든 플레이어들에게 Notify
                bombNotify.NotifyBombDefuse();
                if (bombData.bombState != null)
                    bombData.bombState.BombEvent(EBombState.CLEAR, player.playerIndex);
                Release();
                //RPCDestroy();
            }
        }
    }
    
    public void SetIsInteraction(bool isInteraction)
	{
		isInteracting = isInteraction;
	}

    [PunRPC]
    private void RPCDestroy()
    {
        Release();
    }
    [PunRPC]
    private void PunBombSound(int soundType)
    {
        bombSound.ActiveSound(transform, soundType);
    }
    public override void Use()
    {
        destroyCoroutine = StartCoroutine(SetTimerToDestroy());
    }
    IEnumerator SetTimerToDestroy()
    {
        time = bombTime;
        float beepTime = BombTime - bombSound.beepSoundInterval;
        while (time > 0)
        {
            while (isInteracting) yield return null;
            if (beepTime >= time) 
            {
                bombSound.ActiveSound(transform, (int)EBombSound.BEEP);
                beepTime -= bombSound.beepSoundInterval;
            }
            time -= Time.deltaTime;
            bombNotify.SetTimeCount(time);

            yield return null;
        }
        ShowParticle();
        if (bombData.bombState != null)
            bombData.bombState.BombEvent(EBombState.EXPLOSION, playerIndex);
        bombSound.ActiveSound(transform, (int)EBombSound.EXPLOSION);
        //폭탄 설치한 플레이어 미션 포인트 + 1 이벤트
        if (PhotonNetwork.IsMasterClient)
            PhotonNetwork.RaiseEvent((int)EPointType.MISSION, bombData.nickname, options, SendOptions.SendReliable);

        yield return new WaitForSeconds(0.5f);
        Release();
    }

    public void Defendency(BombData bombData)
    {
        this.bombData = bombData;
    }

    public void DoReset()
    {
        Release();
    }

}
