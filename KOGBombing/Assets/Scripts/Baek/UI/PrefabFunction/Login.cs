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
        NICKNAME,
        MAX,
    }
    enum PanelType
    {
        LOGIN,
        NICKNAME,
        SERVERSELECT,
        MAX,
    }
    enum AccountType
    {
        LOGIN,
        CREATE,
        MAX,
    }
    [SerializeField] GameObject[] _panels = new GameObject[(int)PanelType.MAX];
    [SerializeField] TMPro.TMP_InputField[] _inputFields = new TMPro.TMP_InputField[(int)TextType.MAX];
    [SerializeField] GameObject _loginCreateSwapButton;
    AccountType _accountType = AccountType.LOGIN;
    public void SwapLoginCreate()
    {
        _accountType = (AccountType)(((int)_accountType + 1) % (int)AccountType.MAX);
        _loginCreateSwapButton.transform.GetChild(0).GetComponent<TMPro.TextMeshProUGUI>().text = _accountType.ToString();
    }
    public void OnLoginClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        _panels[(int)PanelType.LOGIN].SetActive(false);
        if(_accountType == AccountType.CREATE)
            Managers.FirebaseAuth.Create(_inputFields[(int)TextType.EMAIL].text, _inputFields[(int)TextType.PW].text);
        else
            Managers.FirebaseAuth.Login(_inputFields[(int)TextType.EMAIL].text, _inputFields[(int)TextType.PW].text);
        StartCoroutine(CheckUserName());
    }
    IEnumerator CheckUserName()
    {
        while(Managers.UserData.userData == null)
        {
            yield return new WaitForSeconds(1.0f);
        }
        if (Managers.UserData.userData.nickName == "User")
            _panels[(int)PanelType.NICKNAME].SetActive(true);
        else
            PhotonNetwork.ConnectUsingSettings();
    }
    public void OnNickNameSetClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.UserData.SettingNickName(_inputFields[(int)TextType.NICKNAME].text);
        _panels[(int)PanelType.NICKNAME].SetActive(false);
        PhotonNetwork.ConnectUsingSettings();
    }
    public override void OnConnectedToMaster()
    {
        _panels[(int)PanelType.SERVERSELECT].SetActive(true);
    }
    public void OnStartClick()
    {
        PhotonNetwork.LocalPlayer.NickName = Managers.UserData.userData.nickName;

        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.SceneLoad.LoadScene("LobbyScene");
    }
}
