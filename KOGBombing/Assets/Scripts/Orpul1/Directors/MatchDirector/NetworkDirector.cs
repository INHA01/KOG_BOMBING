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
