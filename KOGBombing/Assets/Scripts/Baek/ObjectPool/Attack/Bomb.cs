using ExitGames.Client.Photon;
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
public class Bomb : AttackConsum,IDefendencyAble<BombData>
{
    [SerializeField] float bombTime = 10f;
    float time = 0;
    public override float Damage { get { return 0; } }
    Coroutine destroyCoroutine;
    BombNotify bombNotify;
	bool isInteracting = false;
    PhotonView pv;
    BombData bombData;
    RaiseEventOptions options = new RaiseEventOptions();
    int bombEventCode = 50;

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
            bombNotify = Managers.UI.ShowPopupUI<UIPopup>("BombNotifyCanvas").GetComponent<BombNotify>();
        if (bombData.bombState != null)
            bombData.bombState.BombEvent(EBombState.SET);
        bombNotify.NotifyBombSet();
    }
    private void OnTriggerStay(Collider other)
    {
        PlayerBlackBoard player = other.GetComponent<PlayerBlackBoard>();
        if (player != null && player.playerStatus.isBombDefuse)
        {
            player.playerStatus.isBombDefuse = false;
            // 폭탄 해제 모든 플레이어들에게 Notify
            if (bombNotify == null)
                bombNotify = Managers.UI.ShowPopupUI<UIPopup>("BombNotifyCanvas").GetComponent<BombNotify>();
            if (bombData.bombState != null)
                bombData.bombState.BombEvent(EBombState.CLEAR);
            //폭탄 해체한 플레이어 미션 포인트 + 1 이벤트
            if (PhotonNetwork.IsMasterClient)
                PhotonNetwork.RaiseEvent((int)EPointType.MISSION, player.nickname, options, SendOptions.SendReliable);
            bombNotify.NotifyBombDefuse();
            Release();
            //RPCDestroy();
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
}
