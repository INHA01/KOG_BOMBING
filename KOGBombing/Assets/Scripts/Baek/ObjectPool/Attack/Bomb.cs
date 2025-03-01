using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bomb : AttackConsum
{
    [SerializeField] float bombTime = 10f;
    float time = 0;
    public override float Damage { get { return 0; } }
    Coroutine destroyCoroutine;
    BombNotify bombNotify;
	bool isInteracting = false;
    PhotonView pv;

	private void Awake()
	{
		pv = GetComponent<PhotonView>();
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
            bombNotify.NotifyBombSet();
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
        yield return new WaitForSeconds(0.5f);
        Release();
    }

}
