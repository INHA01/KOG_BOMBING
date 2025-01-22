using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PhotonLoginPresenter : MonoBehaviour
{
    [SerializeField]
    PhotonLoginView view;

    public void OnLoginBtn()
    {
        PhotonNetwork.NickName = view.tmpInputNickname.text;
        SceneManager.LoadScene(1);
    }
}
