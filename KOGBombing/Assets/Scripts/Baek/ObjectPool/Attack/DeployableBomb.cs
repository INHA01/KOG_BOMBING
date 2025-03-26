using BAEK;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableBomb : DeployableBase,IDefendencyAble<BombData>
{
    Vector3 position;
    public BombInteraction bombInteraction;
    BombData bombData;
    Bomb bomb;
    RaiseEventOptions options = new RaiseEventOptions();
    public override void SetTeam(ETeam team, int playerIndex)
	{
        base.SetTeam(team, playerIndex);

		if (team == ETeam.REDTEAM)
		{
            bombInteraction = GetComponent<BombInteraction>();
			count = 1;
		}
	}
    public override void Initialize(int count)
    {
        if (count > 0 && playerData.pv.IsMine)
            playScene.subWeaponFades[1].SetActive(false);
        this.count = count;
        if(bomb != null)
            bomb.Release();
        options.Receivers = ReceiverGroup.All;
    }

    public override void Use()
    {
        count--;
        if (count == 0 && playerData.pv.IsMine)
        {
            playScene.subWeaponFades[1].SetActive(true);
        }
        playerData.pv.RPC("PutBomb", RpcTarget.All);
    }

    [PunRPC]
    public virtual void PutBomb()
    {
        StartCoroutine(PutAfterAnim());
    }

    public override void SetWeapon(SupportWeaponInfo info)
    {
        if (consum == null)
            return;

        position = info.Position;
    }
    protected override IEnumerator PutAfterAnim()
    {
        yield return null;
		if ((ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM)
        {
            Bomb myBomb = gameObject.GetComponent<BombInteraction>().GetBomb();
            if (myBomb != null)
                yield break;
            bomb = GetPooledObject().GetComponent<Bomb>();
            bomb.GetComponent<IDefendencyAble<BombData>>().Defendency(bombData);
            bomb.transform.position = playerData.ConsumPos.position;
            bomb.Notify();
            bomb.SetTeam((int)team, playerData);
            bomb.Use();
            GameObject[] players = GameObject.FindGameObjectsWithTag("Player");
            for (int i = 0; i < players.Length; i++)
                players[i].GetComponent<BombInteraction>().SetBomb(bomb);
        }
		else
		{
            Debug.Log("PutAfterAnim");
            if(playerData.pv.IsMine)
            {
                //blackBoard.playerStatus.isBombDefuse = true;
                
                PhotonNetwork.RaiseEvent((int)PunEventType.BOMBEVENT, new object[] { EBombState.CLEAR, playerIndex }, options, SendOptions.SendReliable);
                //player.playerStatus.isBombDefuse = false;
                // ÆøÅº ÇØÁ¦ ¸ðµç ÇÃ·¹ÀÌ¾îµé¿¡°Ô Notify
                Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting).NotifyBombDefuse();
                playerData.pv.RPC("PunBombRelease", RpcTarget.All);
                

                Debug.Log("ÆøÅº ÇØÁ¦");
            }
        }
	}
    [PunRPC]
    private void PunBombRelease()
    {
        PlayerBlackBoard blackBoard = this.GetComponent<PlayerBlackBoard>();
        blackBoard.bombInteraction.Initialize();
    }
    public void Defendency(BombData bombData)
    {
        this.bombData = bombData;
    }
}
