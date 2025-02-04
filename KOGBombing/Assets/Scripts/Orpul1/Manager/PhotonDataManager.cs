using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public struct PlayerKDA
{
    int kill;
    int death;
    int asist;
}
public class PhotonDataManager : MonoBehaviour, IPunObservable
{
    static PhotonDataManager instance;
    public static PhotonDataManager Instance
    { 
        get 
        {
            GameObject obj = GameObject.Find("PunManager");
            if (instance == null)
            {
                obj = new GameObject("PunManager");
                obj.AddComponent<PhotonView>();
                instance = obj.AddComponent<PhotonDataManager>();
            }
            return instance; 
        } 
    }
    [SerializeField]
    PhotonView pView;
    Dictionary<string, PlayerBlackBoard> dicPlayerBlackBoard = new Dictionary<string, PlayerBlackBoard>();
    Dictionary<string, PlayerKDA> dicPlayerKDA = new Dictionary<string, PlayerKDA>();
    [SerializeField]
    List<string> nicknameList = new List<string>();
    string sendId = "";
    public bool IsDataAllGet = false;
    [SerializeField]
    PlayerBlackBoard sendBlackBoard;

    private void Awake()
    {
        if(instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
            return;
        }
        else
        {
            Destroy(gameObject);
        }
    }
    public void AddPlayerBlackBoard(string nickname, PlayerBlackBoard blackBoard)
    {
        Debug.Log($"add ID {blackBoard.nickname}");
        dicPlayerBlackBoard.Add(nickname, blackBoard);
        sendId = nickname;
        sendBlackBoard = blackBoard;
        nicknameList.Add(nickname);
        if (PhotonNetwork.PlayerList.Length == dicPlayerBlackBoard.Count)
            IsDataAllGet = true;
    }
    public PlayerBlackBoard GetPlayerBlackBoard(string nickname)
    {
        if(!dicPlayerBlackBoard.ContainsKey(nickname))
        {
            Debug.Log("NULL blackBoard!");
            return null;
        }
        return dicPlayerBlackBoard[nickname];
    }
    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
        if(stream.IsWriting)
        {
            stream.SendNext(sendId);
            stream.SendNext(sendBlackBoard);
        }
        else if(stream.IsReading)
        {
            string reciveId = (string)stream.ReceiveNext();
            if (!dicPlayerBlackBoard.ContainsKey(reciveId))
            {
                dicPlayerBlackBoard.Add(reciveId, (PlayerBlackBoard)stream.ReceiveNext());
            }
        }
    }

}
