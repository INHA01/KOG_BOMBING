using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class NetworkDirector : MonoBehaviourPunCallbacks
    {
        [SerializeField]
        protected string sampleUserId = "";
        AuthenticationValues authValue = new AuthenticationValues();

        [SerializeField]
        RandomMatch RandomMatch;
        /*[SerializeField]
        CustomMatch CustomMatch;*/
        IMatchAble customMatch, randomMatch;
        private void Start()
        {
            randomMatch = RandomMatch;
            //customMatch = CustomMatch;
            //authValue.AuthType = CustomAuthenticationType.Custom;
            /*
            authValue.AddAuthParameter("UserID", sampleUserId);
            authValue.UserId = sampleUserId;
            PhotonNetwork.AuthValues = authValue;
    */
            PhotonNetwork.ConnectUsingSettings();
            Debug.Log("ConnectMasterServer!");
        }
        public override void OnCustomAuthenticationFailed(string debugMessage)
        {
            Debug.Log($"authen {debugMessage}");
        }
        public override void OnConnectedToMaster()
        {
            // Debug.Log($"userid: {PhotonNetwork.LocalPlayer.UserId}");
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
