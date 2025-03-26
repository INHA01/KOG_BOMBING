using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Orpul1
{
    public enum EScene
    {
        LobbyScene,
        MainGame,
        END
    }
    public class CrossHairController : UIPopup, IChangeHitCursorAble, ISetPunInfo
    {
        [SerializeField] GameObject cursorObj;
        [SerializeField] Image cursorUI;
        [SerializeField] List<Sprite> cursorList = new List<Sprite>();
        [SerializeField] Camera crossHairCamera;
        [SerializeField] Canvas cursorCanvas;
        [SerializeField] Animator cursorAnimation;
        Dictionary<string, Sprite> dictCusrsor = new Dictionary<string, Sprite>();
        EScene curCursor = EScene.LobbyScene;
        ETeam playerTeam;
        int playerIndex = 0;
        void Reset()
        {
            cursorList.Clear();
            cursorObj = transform.GetChild(0).gameObject;
            cursorUI = cursorObj.transform.GetChild(1).GetComponent<Image>();
            Sprite cursorHair06 = Resources.Load<Sprite>("UISettings/CrossHair/Crosshair_06");
            Sprite cursorHair03 = Resources.Load<Sprite>("UISettings/CrossHair/Crosshair_03");
            cursorList.Add(cursorHair06);
            cursorList.Add(cursorHair03);
            cursorCanvas = GetComponent<Canvas>();
            cursorAnimation = GetComponent<Animator>();
        }
        void Start()
        {
            Canvas canvas = Util.GetOrAddComponent<Canvas>(gameObject);
            canvas.sortingOrder = 30001;
            SceneManager.sceneLoaded += UpdateCursor;
            for (int i = 0; i < (int)EScene.END; i++)
            {
                EScene type = (EScene)i;
                dictCusrsor.Add(type.ToString(), cursorList[i]);
            }
            Cursor.visible = false;
        }
        void Update()
        {
            cursorObj.transform.position = Input.mousePosition;
        }
        private void UpdateCursor(Scene arg, LoadSceneMode mode)
        {
            Cursor.visible = false;
            if (!dictCusrsor.ContainsKey(arg.name)) return;
            Sprite cursorTexture = dictCusrsor[arg.name];
            cursorUI.sprite = cursorTexture;
        }
        public void ChangeHitCursor(int playerIndex, ETeam playerTeam)
        {
            if (this.playerIndex != playerIndex) return;
            if (this.playerTeam != playerTeam) return;

            cursorAnimation.SetTrigger("HitCursor");
        }

        public void SetPunInfo(ETeam team, int playerIndex)
        {
            playerTeam = team;
            this.playerIndex = playerIndex;
        }
    }
}