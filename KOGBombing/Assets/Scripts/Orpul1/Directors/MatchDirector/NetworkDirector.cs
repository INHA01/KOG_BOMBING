using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace Orpul1
{
    public class NetworkDirector : MonoBehaviourPunCallbacks
    {
        [SerializeField]
        PhotonMatch randomMatch;
        [SerializeField]
        PhotonMatch customMatch;

        [SerializeField]
        Button btnRandomMatch;
        [SerializeField]
        Button btnCustomMatch;
        
        private void Start()
        {
            btnRandomMatch.interactable = false;
            btnCustomMatch.interactable = false;
            Debug.Log("Try ConnectMaster");
            PhotonNetwork.ConnectUsingSettings();
        }
        public override void OnCustomAuthenticationFailed(string debugMessage)
        {
            Debug.Log($"authen {debugMessage}");
        }
        public override void OnConnectedToMaster()
        {
            Debug.Log("ConnectMasterServer!");
            btnRandomMatch.interactable = true;
            btnCustomMatch.interactable = true;
        }

        public void onRandomMatch()
        {
            randomMatch.Match();
        }
        public void onCustomMatch()
        {
            customMatch.Match();
        }
    }
}
