using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class RoundEndWaiter : PhotonPlayerWaitLogic
    {
        public override void EnterState()
        {
            base.EnterState();
            //PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { ""} })
        }
        public override void UpdateState()
        {
        }
        public override void ExitState()
        {
        }

        protected override void SetCurReadyPlayer()
        {
        }

        protected override IEnumerator CoWaitPlayer()
        {
            yield return null;
        }

       
    }

}
