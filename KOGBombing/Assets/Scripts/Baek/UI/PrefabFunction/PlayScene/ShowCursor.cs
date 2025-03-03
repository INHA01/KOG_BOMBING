using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;
using UnityEngine.UI;

public class ShowCursor : MonoBehaviour
{
    [SerializeField] Vector3 bombPos;
    [SerializeField] GameObject cursor;
    public Vector3 BombPos { get { return bombPos; }  set { bombPos = value; } }
    Camera main;
    void OnEnable()
    {
        main = Managers.CamData.GetCamera(ECameraType.MAINCAMERA).GetComponent<Camera>();
    }
    void FixedUpdate()
    {
        if (main == null) return;
        Vector3 bombDir = bombPos - main.transform.position;
        // 카메라가 bombPos를 바라보고 있는지 확인
        Debug.Log("main" + main.transform.forward);
        Debug.Log("Cursor" + Vector3.Dot(main.transform.forward, bombDir.normalized));
        if (Vector3.Dot(main.transform.forward, bombDir.normalized) < 0)
        {
            // 카메라가 bombPos의 반대편을 바라보고 있다면 bombDir 반전
            bombDir = -bombDir;
        }
        // 폭탄의 방향으로 커서 위치 , 화면 밖으로 나가지 않게
        Vector3 cursorPos = main.WorldToScreenPoint(main.transform.position + bombDir.normalized * 10);
        cursorPos.x = Mathf.Clamp(cursorPos.x, 0, Screen.width - 90);
        cursorPos.y = Mathf.Clamp(cursorPos.y, 0, Screen.height - 90);
        cursor.transform.position = cursorPos;
    }
}
