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
        SIGN_UP_EMAIL,
        SIGN_UP_PW,
        MAX,
    }
    enum PanelType
    {
        LOGIN,
        NICKNAME,
        SERVERSELECT,
        MAX,
    }
    public enum AccountType
    {
        LOGIN,
        CREATE,
        MAX,
    }
    enum ButtonType
    {
        SWAP,
        GUEST,
        MAX,
    }

    [SerializeField] GameObject[] _panels = new GameObject[(int)PanelType.MAX];
    [SerializeField] TMPro.TMP_InputField[] _inputFields = new TMPro.TMP_InputField[(int)TextType.MAX];
    [SerializeField] GameObject[] _buttons = new GameObject[(int)ButtonType.MAX];
    [SerializeField] Animator splashScreenAnimator;
    AccountType _accountType = AccountType.LOGIN;
    Coroutine checkLogin;

    public void SwapLoginCreate()
    {
        _accountType = (AccountType)(((int)_accountType + 1) % (int)AccountType.MAX);
        _buttons[(int)ButtonType.SWAP].transform.GetChild(0).GetComponent<TMPro.TextMeshProUGUI>().text = _accountType.ToString();
    }

    public void OnLoginClick(int type)  // create와 login 분리하면서 버튼에 따라 type 넣어서 이벤트 진행되도록 함
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        // >> :Button Disable
        _panels[(int)PanelType.LOGIN].SetActive(false);
        for (int i = 0; i < (int)ButtonType.MAX; i++)
        {
            _buttons[i].SetActive(false);
        }
        // << :Button Disable
        if (type == (int)AccountType.CREATE)
            Managers.FirebaseAuth.Create(_inputFields[(int)TextType.EMAIL].text, _inputFields[(int)TextType.PW].text);
        else
            Managers.FirebaseAuth.Login(_inputFields[(int)TextType.EMAIL].text, _inputFields[(int)TextType.PW].text);
        if (checkLogin == null)
            checkLogin = StartCoroutine(CheckLoginSuccess());
    }

    IEnumerator CheckLoginSuccess()
	{
		yield return new WaitForSeconds(1f);
        if(Managers.FirebaseAuth.isLogin)
        {
            StartCoroutine(CheckUserName());
		}
        else
        {
            //_panels[(int)PanelType.LOGIN].SetActive(true);

            splashScreenAnimator.Play("Login Failed", -1, 0f);
			//for (int i = 0; i < (int)ButtonType.MAX; i++)
   //         {
   //             _buttons[i].SetActive(true);
   //         }
        }
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
        checkLogin = null;

	}
    public void OnGuestClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.UserData.userData = new UserData("User");
        Managers.UserData.userData.nickName = "User" + Random.Range(0, 1000);
        _panels[(int)PanelType.LOGIN].SetActive(false);
        for(int i = 0; i < (int)ButtonType.MAX; i++)
        {
            _buttons[i].SetActive(false);
        }
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
        splashScreenAnimator.Play("Login Success");
    }
    public void OnStartClick()
    {
        PhotonNetwork.LocalPlayer.NickName = Managers.UserData.userData.nickName;

        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.SceneLoad.LoadScene("LobbyScene");
    }
}
