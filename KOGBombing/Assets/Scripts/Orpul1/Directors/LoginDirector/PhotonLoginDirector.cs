using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PhotonLoginDirector : MonoBehaviourPunCallbacks
{
    StringBuilder stbId = new StringBuilder();
    StringBuilder stbPass = new StringBuilder();
    public void OnLoginBtn()
    {
        // >> TODO : 로그인 버튼 누를 시 발생하는 콜백 함수
        GetIDPassInfo();
        if (!IsCorrectLoginInfo()) return;
        PhotonNetwork.ConnectUsingSettings();
    }    
    public override void OnConnectedToMaster()
    {
        // >> TODO : ID, PASSWORD 가 일치 할 경우 다음 씬으로 넘어가도록 설정
        LoadMainScene();
    }
    private void GetIDPassInfo()
    {
        // >> TODO: 플레이어가 작성한 ID, PASSWORD 가져오기
        stbId.Clear();
        stbPass.Clear();
        stbId.Append("testID");
        stbPass.Append("testPass");
    }
    private bool IsCorrectLoginInfo()
    {
        // >> TODO : 파이어 베이스 서버에서 같은 ID, PASSWORD가 있는 지 확인하는 코드 작성해야 함.
        if (stbId.ToString() != "testID") return false;
        if (stbPass.ToString() != "testPass") return false;
        return true;
    }
    private void LoadMainScene()
    {
        //>> TODO : 비동기 로딩 씬으로 로딩 씬으로 넘어가도록 해야함
        SceneManager.LoadScene(1);
    }
}
