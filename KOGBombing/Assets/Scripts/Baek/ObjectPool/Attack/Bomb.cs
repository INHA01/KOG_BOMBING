using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bomb : AttackConsum
{
    public override float Damage { get { return 0; } }
    Coroutine destroyCoroutine;
    void Awake()
    {
        // 폭탄 설치 모든 플레이어들에게 Notify
    }
    private void OnTriggerStay(Collider other)
    {
        PlayerBlackBoard player = other.GetComponent<PlayerBlackBoard>();
        if (player != null && player.playerStatus.isBombDefuse)
        {
            player.playerStatus.isBombDefuse = false;
            Release();
            //RPCDestroy();
        }
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
        yield return new WaitForSeconds(10f);
        ShowParticle();
        yield return new WaitForSeconds(0.5f);
        Release();
    }

}
