using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bomb : AttackConsum
{
    public override float Damage { get { return 0; } }
    Coroutine destroyCoroutine;
    UIPopup _uiScene;
    bool isInteracting = false;
    
    public void Notify()
    {
        // 폭탄 설치 모든 플레이어들에게 Notify
        NotifySet();
    }
    void NotifySet()
    {
        if (_uiScene == null)
            _uiScene = Managers.UI.ShowPopupUI<UIPopup>("BombNotifyCanvas");
        _uiScene.GetComponent<BombNotify>().NotifyBombSet();
    }
    private void OnTriggerStay(Collider other)
    {
        PlayerBlackBoard player = other.GetComponent<PlayerBlackBoard>();
        if (player != null && player.playerStatus.isBombDefuse)
        {
            player.playerStatus.isBombDefuse = false;
            // 폭탄 해제 모든 플레이어들에게 Notify
            if(_uiScene == null)
				_uiScene = Managers.UI.ShowPopupUI<UIPopup>("BombNotifyCanvas");
			_uiScene.GetComponent<BombNotify>().NotifyBombDefuse();
            Release();
            //RPCDestroy();
        }
    }

    public void SetIsInteraction(bool isInteraction)
    {
        RPCSetIsInteraction(isInteraction);
    }

    [PunRPC]
    public void RPCSetIsInteraction(bool isInteraction)
    {
		this.isInteracting = isInteraction;
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
		float time = 0;
        while (true)
        {
            while (isInteracting) yield return null;
            if (time >= 10.0f)
                break;
            Debug.Log("Show, Time: " + time);
            time += Time.deltaTime;
            yield return null;
		}
        ShowParticle();
        yield return new WaitForSeconds(0.5f);
        Release();
    }

}
