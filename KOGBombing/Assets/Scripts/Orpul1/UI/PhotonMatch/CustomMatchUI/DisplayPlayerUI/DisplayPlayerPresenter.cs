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
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        transform.SetParent(trTeam);
    }
    public void UpdateUI()
    {
        view.tmpNickname.text = model.PlayerNickname.ToString();
        view.tmpLevel.text = model.PlayerLevel.ToString();
    }
    
}
