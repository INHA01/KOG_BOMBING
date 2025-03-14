using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public struct BombData
{
    public string nickname;
    public IBombStateAble bombState;
}
public class Bomb : AttackConsum,IDefendencyAble<BombData>,IResetAble
{
    [SerializeField] float bombTime = 20f;
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
            bombData.bombState.BombEvent(EBombState.SET);
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
                    bombData.bombState.BombEvent(EBombState.CLEAR);
                //폭탄 해체한 플레이어 미션 포인트 + 1 이벤트
                if (PhotonNetwork.IsMasterClient)
                    PhotonNetwork.RaiseEvent((int)EPointType.MISSION, player.nickname, options, SendOptions.SendReliable);
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
    public override void Use()
    {
        destroyCoroutine = StartCoroutine(SetTimerToDestroy());
    }
    IEnumerator SetTimerToDestroy()
    {
        time = bombTime;
        while (time > 0)
        {
            while (isInteracting) yield return null;
            time -= Time.deltaTime;
            bombNotify.SetTimeCount(time);

            yield return null;
        }
        ShowParticle();
        if(bombData.bombState!= null)
            bombData.bombState.BombEvent(EBombState.EXPLOSION);
        //폭탄 설치한 플레이어 미션 포인트 + 1 이벤트
        if(PhotonNetwork.IsMasterClient)
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
