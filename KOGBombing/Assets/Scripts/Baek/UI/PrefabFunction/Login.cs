using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public class Login : MonoBehaviourPunCallbacks
{
    enum TextType
    {
        EMAIL,
        PW,
        MAX,
    }
    [SerializeField] GameObject _login;
    [SerializeField] GameObject _serverSelect;
    [SerializeField] TMPro.TMP_InputField[] _inputFields = new TMPro.TMP_InputField[(int)TextType.MAX];
    public void OnLoginClick()
    {
        _login.SetActive(false);
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        PhotonNetwork.ConnectUsingSettings();
    }
    public override void OnConnectedToMaster()
    {
        _serverSelect.SetActive(true);
    }
    public void OnStartClick()
    {
        if (_inputFields[(int)TextType.EMAIL].text == "")
            _inputFields[(int)TextType.EMAIL].text = Managers.UserData.userData.nickName + (Random.Range(0, 100) * Time.deltaTime).ToString();
        Managers.UserData.userData.nickName = _inputFields[(int)TextType.EMAIL].text;
        PhotonNetwork.LocalPlayer.NickName = _inputFields[(int)TextType.EMAIL].text;
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        LoadingSceneManager.LoadScene("LobbyScene");
    }
}
