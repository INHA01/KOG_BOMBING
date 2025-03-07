using Photon.Pun;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

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
        private void Start()
        {
            PhotonHashtable playerTeam = new PhotonHashtable { { EPropertyType.TEAM.ToString(), ETeam.REDTEAM } };
            PhotonNetwork.LocalPlayer.SetCustomProperties(playerTeam);
        }
        public void Match(EMatchType mode)
        {
            match[(int)mode].Match();
        }
    }
}
