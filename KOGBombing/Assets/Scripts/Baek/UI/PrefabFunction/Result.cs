using BAEK;
using Michsky.UI.Shift;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public enum ResultType
{
    Win,
    Lose,
    Max
}
public class Result : MonoBehaviour
{
    enum ButtonPos
    {
        Left,
        Right,
        Max
    }
    enum ResultButton
    {
        MoveMVP,
        MoveLobby,
        MoveTeamRecord,
        MoveResult,
        Max
    }
    enum RecordType
    {
        Misson,
        Kill,
        Death,
        Max
    }
    [SerializeField] Transform[] buttonPos = new Transform[(int)ButtonPos.Max];
    [SerializeField] GameObject[] resultButton = new GameObject[(int)ResultButton.Max];
    [Header("MVP")]
    [SerializeField] GameObject[] resultText = new GameObject[2];
    ResultType type;
    int[] teamScore = new int[2] { 0, 0 };
    int[] teamKillScore = new int[2] { 0, 0 };
    int[] teamDeathScore = new int[2] { 0, 0 };
    [Header("Record")]
    [SerializeField] GameObject resultRecord;
    [SerializeField] TextMeshProUGUI[] levelText = new TextMeshProUGUI[2];
    [SerializeField] Slider recordBar;
    [SerializeField] TextMeshProUGUI[] recordText = new TextMeshProUGUI[(int)RecordType.Max];
    [SerializeField] Image[] recordFrame = new Image[(int)RecordType.Max];
    [SerializeField] AudioClip levelUpBarAudio;
    int currentLevel;
    float currentExp;

    Coroutine fillBar;
    bool isFillFinish = false;
    PlayerPointInfo resultInfo;
    void OnEnable()
    {
        // >> Record 데이터 초기화
        currentLevel = Managers.UserData.userData.level;
        levelText[0].text = currentLevel.ToString();
        levelText[1].text = (currentLevel + 1).ToString();
        currentExp = Managers.UserData.userData.exp;
        resultInfo = Managers.PointData.GetPlayerInfo(PhotonNetwork.LocalPlayer.NickName);
        recordText[(int)RecordType.Misson].text = resultInfo.MissionPoint.ToString();
        LoadRecordFrame(resultInfo.MissionPoint, RecordType.Misson);
        recordText[(int)RecordType.Kill].text = resultInfo.KillPoint.ToString();
        LoadRecordFrame(resultInfo.KillPoint, RecordType.Kill);
        recordText[(int)RecordType.Death].text = resultInfo.DeathPoint.ToString();
        LoadRecordFrame(resultInfo.DeathPoint, RecordType.Death);
        // << Record 데이터 초기화

        WinnerTeam myTeam = (WinnerTeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        type = Managers.RoundData.WinTeam == myTeam ? ResultType.Win : ResultType.Lose;
        for(int i = 0; i < (int)ResultType.Max; i++)
        {
            if(i==(int)type)
                resultText[i].gameObject.SetActive(true);
            else
                resultText[i].gameObject.SetActive(false);
        }
        GameObject resultAvatar = Managers.Resource.Instantiate(FactoryType.SupportUI, (int)SupportUI.ResultAvatar);
        resultAvatar.GetComponent<ISetWinTypeable>().SetWinType((ResultTeam)type);
        // 데이터 저장
        SaveRecordData();
    }

    
    public void OpenMVP()
    {
        if (fillBar != null) return;
        // 왼쪽 : 없음 , 오른쪽 : 팀기록
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Right]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector2.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
    }
    public void OpenTeamRecord()
    {
        if (fillBar != null) return;
        BattleBoardUpdater battleBoard = Managers.UI.ShowPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard);
		battleBoard.SetHalfRound(ERoundState.RESULT);
		resultRecord.SetActive(false);
        // 왼쪽 : MVP , 오른쪽 : 결과창
        resultButton[(int)ResultButton.MoveMVP].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(true);
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(false);
        resultButton[(int)ResultButton.MoveLobby].SetActive(false);
    }
    
    public void OpenResult()
    {
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
        resultRecord.SetActive(true);
        // 왼쪽 : 팀기록 , 오른쪽 : 로비
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Left]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector2.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveLobby].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        if(fillBar == null && !isFillFinish)
        {
            fillBar = StartCoroutine(FillBar());
        }
    }
    void LoadRecordFrame(int score, RecordType type)
    {
        int frameIndex = 0;
        if (score > 5)
            frameIndex = 2;
        else if (score > 3)
            frameIndex = 1;
        recordFrame[(int)type].sprite = Managers.Resource.LoadImg(ImgLoaderType.Frame, frameIndex + 31);
    }

    void SaveRecordData()
    {
        float addExp = type == ResultType.Win ? 500 : 200;
        float maxExp = currentLevel * 300;
        float saveExp = Managers.UserData.userData.exp + addExp;
        if (saveExp >= maxExp)
        {
            Managers.UserData.userData.level++;
            saveExp -= maxExp;
        }
        Managers.UserData.userData.exp = saveExp;
        Managers.UserData.userData.kill += resultInfo.KillPoint;
        Managers.UserData.userData.death += resultInfo.DeathPoint;
        Managers.UserData.userData.assist += resultInfo.AsistPoint;
        Managers.UserData.userData.mission += resultInfo.MissionPoint;
        if (type == ResultType.Win)
        {
            Managers.UserData.userData.win++;
        }
        else
        {
            Managers.UserData.userData.lose++;
        }
        Managers.UserData.SaveUserData();
    }
    IEnumerator FillBar()
    { 
        // 이기면 경험치 500, 지면 200
        // 경험치 총량은 level * 300
        int nextLevel = currentLevel + 1;
        float maxExp = currentLevel * 300;
        float increaseExp = type == ResultType.Win ? 500 : 200;
        float amount = 0;

        Managers.Sound.PlayEffect(levelUpBarAudio, EMixerGroup.UISOUND);
        while (amount <= increaseExp)
        {
            currentExp += 1;
            amount += 1;
            recordBar.value = currentExp / maxExp;
            if(currentExp >= maxExp)
            {
                currentLevel++;
                nextLevel++;
                currentExp = 0;
                maxExp = currentLevel * 300;
                levelText[0].text = currentLevel.ToString();
                levelText[1].text = nextLevel.ToString();
            }
            yield return new WaitForSeconds(0.001f);
        }
        
        isFillFinish = true;
        yield return new WaitForSeconds(2f);
        fillBar = null;
    }
    public void ReturnLobby()
    {
        if (fillBar != null) return;
        InitScreen();
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Initialize();
        Managers.UI.GetPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard).ResetPlayerScore();
        Managers.SceneLoad.LoadScene("LobbyScene");
    }
    void InitScreen()
    {
        isFillFinish = false;
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Right]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector2.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultButton[(int)ResultButton.MoveLobby].SetActive(false);
        resultRecord.SetActive(false);
    }
}
