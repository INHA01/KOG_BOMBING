using System.Collections;
using System.Text;
using UnityEngine;
using static Cinemachine.DocumentationSortingAttribute;

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
        transform.SetParent(trTeam);
    }
    public void UpdateUI()
    {
        view.tmpNickname.text = model.PlayerNickname.ToString();
        view.tmpLevel.text = model.PlayerLevel.ToString();
    }
    
}
