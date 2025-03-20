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
    public enum AccountType
    {
        LOGIN,
        CREATE,
        MAX,
    }
    [SerializeField] TMPro.TMP_InputField[] _inputFields = new TMPro.TMP_InputField[(int)TextType.MAX];
    [SerializeField] Animator splashScreenAnimator;
    Coroutine checkLogin;
    public void OnLoginClick(int type)  // create와 login 분리하면서 버튼에 따라 type 넣어서 이벤트 진행되도록 함
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        int time = 0;
        if (type == (int)AccountType.CREATE)
        {
            Managers.FirebaseAuth.Create(_inputFields[(int)TextType.SIGN_UP_EMAIL].text, _inputFields[(int)TextType.SIGN_UP_PW].text, _inputFields[(int)TextType.NICKNAME].text);
            time = 5;
        }
        else
        {
            Managers.FirebaseAuth.Login(_inputFields[(int)TextType.EMAIL].text, _inputFields[(int)TextType.PW].text);
            time = 1;
        }
        // 여기서 로그인,회원가입 성공 여부 확인
        if (checkLogin == null)
            checkLogin = StartCoroutine(CheckLoginSuccess(time));
    }

    IEnumerator CheckLoginSuccess(int time)
	{
		// 여기에 로그인 중, 혹은 회원가입 중 패널 띄우기
		splashScreenAnimator.Play("Loading", -1, 0f);
		yield return new WaitForSeconds(time);
        splashScreenAnimator.Play("Loading Out", -1, 0f);
		checkLogin = null;
		if (Managers.FirebaseAuth.isLogin)
        {
            StartCoroutine(CheckUserName());
		}
        else
        {
            splashScreenAnimator.Play("Login Failed", -1, 0f);
        }
    }
    IEnumerator CheckUserName()
    {
        while(Managers.UserData.userData == null)
        {
            yield return new WaitForSeconds(1.0f);
		}
        if (Managers.UserData.userData.nickName == "User")
            Managers.UserData.SettingNickName("User" + Random.Range(0, 1000));

        PhotonNetwork.ConnectUsingSettings();
	}
    public void OnGuestClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.UserData.userData = new UserData("User");
        Managers.UserData.userData.nickName = "User" + Random.Range(0, 1000);
        PhotonNetwork.ConnectUsingSettings();
    }
    public override void OnConnectedToMaster()
    {
        splashScreenAnimator.Play("Login Success");
		PhotonNetwork.LocalPlayer.NickName = Managers.UserData.userData.nickName;

		Managers.Sound.PlayUISound(EUiSoundType.CLICK);
		Managers.SceneLoad.LoadScene("LobbyScene");
	}
}
