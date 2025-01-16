using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using UnityEngine;

namespace Orpul1
{
    public class GameDirector : MonoBehaviour
    {
        [SerializeField]
        GameObject playerCamera;
        private void Awake()
        {
            Application.targetFrameRate = 60;
        }
        void Start()
        {
            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefs/Player", Vector3.zero, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            Debug.Log("test");
        }
    }
}
