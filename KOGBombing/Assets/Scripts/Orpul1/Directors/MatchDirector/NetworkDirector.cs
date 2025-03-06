using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

namespace Orpul1
{
    public enum EMatchType
    {
        RANDOM,
        CUSTOM
    }
    public class NetworkDirector : MonoBehaviour
    {
        [SerializeField] PhotonMatch[] match;
        public void Match(EMatchType mode)
        {
            match[(int)mode].Match();
        }
    }
}
