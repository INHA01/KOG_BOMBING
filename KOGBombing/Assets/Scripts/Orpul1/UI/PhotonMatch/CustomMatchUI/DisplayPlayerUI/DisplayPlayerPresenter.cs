using Photon.Pun.Demo.PunBasics;
using System.Text;
using UnityEngine;

public class DisplayPlayerPresenter : MonoBehaviour
{
    [SerializeField] DisplayPlayerView view;
    DisplayPlayerModel model;
    
    public void Init(StringBuilder nickname, StringBuilder level)
    {
        model = new DisplayPlayerModel(UpdateUI);
        model.SetPlayerInfo(nickname, level);
    }

    public void SetTeam(Transform trTeam)
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        transform.SetParent(trTeam);
    }
    public void UpdateUI()
    {
        for (int i = 0; i < (int)EPlayerTextUI.END; i++)
            view.tmpPlayerInfos[i].text = model.PlayerInfos[i].ToString();
    }
    
}
