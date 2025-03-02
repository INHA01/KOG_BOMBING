using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Orpul1
{
    public class NetworkDirector : MonoBehaviour
    {
        [SerializeField]
        PhotonMatch randomMatch;
        [SerializeField]
        PhotonMatch customMatch;
        private void Start()
        {
            PhotonNetwork.LocalPlayer.NickName = Managers.UserData.userData.nickName;
        }
        public void Match(int mode)
        {
            Debug.Log("match");
            if(mode == 0)
            {
                randomMatch.Match();
            }
            else
            {
                customMatch.Match();
            }
        }
    }
}
