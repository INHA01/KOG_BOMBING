using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;
using UnityEngine.UI;

public class ShowCursor : MonoBehaviour
{
    enum SounCursorType
    {
        Effect,
        Shoot,
        Walk,
        Max,
    }
    struct ScreenPos
    {
        public Vector3 canvasPos;
        public float minX;
        public float maxX;
        public float minY;
        public float maxY;
    }
    [SerializeField] Vector3 bombPos;
    [SerializeField] GameObject cursor;
    [SerializeField] GameObject cursorParent;
    Camera main;
    ScreenPos screenPos;
    float cursorLength;
    public List<GameObject> soundCursor = new List<GameObject>();
    public Vector3 BombPos { get { return bombPos; }  set { bombPos = value; } }
    void OnEnable()
    {
        cursorLength = cursor.GetComponent<RectTransform>().sizeDelta.x / 2;
        screenPos.canvasPos = GetComponent<Canvas>().transform.position;
        screenPos.minX = screenPos.canvasPos.x - (Screen.width / 2 - cursorLength);
        screenPos.maxX = screenPos.canvasPos.x + (Screen.width / 2 - cursorLength);
        screenPos.minY = screenPos.canvasPos.y - (Screen.height / 2 - cursorLength);
        screenPos.maxY = screenPos.canvasPos.y + (Screen.height / 2 - cursorLength);
        main = Managers.CamData.GetCamera(ECameraType.MAINCAMERA).GetComponent<Camera>();
    }
    void FixedUpdate()
    {
        if (main == null) return;
        Vector3 bombDir = bombPos - main.transform.position;
        cursor.transform.position = CursorScreenSet(bombDir);
    }
    Vector3 CursorScreenSet(Vector3 dir)
    {
        // 지정된 방향으로 커서 위치 , 화면 밖으로 나가지 않게
        Vector3 cursorPos = main.WorldToScreenPoint(main.transform.position + dir.normalized * 10);
        cursorPos.x = Mathf.Clamp(cursorPos.x, screenPos.minX, screenPos.maxX);
        cursorPos.y = Mathf.Clamp(cursorPos.y, screenPos.minY, screenPos.maxY);
        float dot = Vector3.Dot(main.transform.forward, dir.normalized);
        // 내적각도가 90도 이상인 경우 커서 위치를 반대로 (시야가 반대방향인 경우)
        if (dot <= 0)
        {
            cursorPos.x = screenPos.canvasPos.x - (cursorPos.x - screenPos.canvasPos.x);
            cursorPos.y = screenPos.canvasPos.y - (cursorPos.y - screenPos.canvasPos.y);
        }
        return cursorPos;
    }
    public void ShowSoundCursor(Vector3 soundPos , bool isShoot , PlayerBlackBoard player)
    {
        GameObject soundEffect = null;
        for (int i=0; i< soundCursor.Count; i++)
        {
            if(soundCursor[i].activeSelf==false)
                soundEffect = soundCursor[i];
        }
        if(soundEffect == null)
            soundEffect = Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/SoundCursor", cursorParent.transform);
        else
            soundEffect.SetActive(true);
        soundCursor.Add(soundEffect);
        if(isShoot)
        {
            soundEffect.transform.GetChild((int)SounCursorType.Shoot).gameObject.SetActive(true);
            soundEffect.transform.GetChild((int)SounCursorType.Walk).gameObject.SetActive(false);
        }
        else
        {
            soundEffect.transform.GetChild((int)SounCursorType.Shoot).gameObject.SetActive(false);
            soundEffect.transform.GetChild((int)SounCursorType.Walk).gameObject.SetActive(true);
        }
        StartCoroutine(SoundCursorEffect(soundPos , soundEffect,player));
    }
    IEnumerator SoundCursorEffect(Vector3 soundPos , GameObject go, PlayerBlackBoard player)
    {
        float time = 0;
        while(true)
        {
            Vector3 dir = soundPos - main.transform.position;
            go.transform.position = CursorScreenSet(dir);
            time += Time.deltaTime;
            if(time > 3f)
                break;
            yield return null;
        }
        player.showSoundEffect = false;
        go.SetActive(false);
    }
}
