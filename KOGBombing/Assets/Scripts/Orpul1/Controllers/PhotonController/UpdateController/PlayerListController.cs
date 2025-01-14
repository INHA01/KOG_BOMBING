using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class PlayerListController : PhotonUpdateController<Player>
    {
        //Dictionary<string, DisplayPlayerPresenter> dicPlayerInfo = new Dictionary<string, DisplayPlayerPresenter>();
        public override void UpdateInfo(Player playerInfo)
        {

        }
    }
}