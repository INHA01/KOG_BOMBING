using System.Text;
using UnityEngine;

public class DisplayPlayerPresenter : MonoBehaviour
{
    public enum ETeamType
    {
        REDTEAM,
        BLUETEAM
    }
    [SerializeField] DisplayPlayerView view;
    DisplayPlayerModel model = new DisplayPlayerModel();
    
    public void Init(StringBuilder nickname, StringBuilder level)
    {
        model.stbNickname.Clear();
        model.stbLevel.Clear();
        model.stbNickname.Append(nickname.ToString());
        model.stbLevel.Append(level.ToString());
        view.tmpNickname.text = nickname.ToString();
        view.tmpLevel.text = level.ToString();
    }

    public void SetTeam(Transform trTeam)
    {
        transform.SetParent(trTeam);
    }
    
}
