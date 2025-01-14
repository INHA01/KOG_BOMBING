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
        /*[SerializeField]
        protected string sampleUserId = "";
        AuthenticationValues authValue = new AuthenticationValues();
        */
        [SerializeField]
        string playerNickname = "";
        [SerializeField]
        GameObject RandomMatchObj;
        [SerializeField]
        GameObject CustomMatchObj;

        [SerializeField]
        Button btnRandomMatch;
        [SerializeField]
        Button btnCustomMatch;

        IMatchAble customMatch, randomMatch;
        private void Start()
        {
            randomMatch = RandomMatchObj.GetComponent<RandomMatchDirector>();
            customMatch = CustomMatchObj.GetComponent<CustomMatchDirector>();
            btnRandomMatch.interactable = false;
            btnCustomMatch.interactable = false;

            PhotonNetwork.LocalPlayer.NickName = playerNickname;
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
