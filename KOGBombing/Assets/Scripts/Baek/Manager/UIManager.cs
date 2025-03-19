using BAEK;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Diagnostics;

public class UIManager
{
    public GameObject Root
    {
        get
        {
            GameObject root = GameObject.Find("@UI_Root");
            if (root == null)
                root = new GameObject { name = "@UI_Root" };
            return root;
        }
    }
    int _order = 0;
    //value
    public UIPopup[] _popupArray = new UIPopup[(int)UIKEY.Max];
    //key
    public UIKEY[] _popupKey = new UIKEY[(int)UIKEY.Max];

    public void Init()
    {
        _order = 0;
        for (int i = 0; i < (int)UIKEY.Max; i++)
        {
            _popupKey[i] = UIKEY.NONE;
        }
    }
    int GetHash(UIKEY key)
    {
        int hash = key.GetHashCode();
        return Mathf.Abs(hash) % (int)UIKEY.Max;
    }

    public T GetPopupUI<T>(UIKEY name) where T : UIPopup
    {
        if (name == UIKEY.NONE) return null;
        int index = GetHash(name);
        if (_popupKey[index].Equals(name))
        {
            return _popupArray[index].GetComponent<T>();
        }
        return ShowPopupUI<T>(name);
    }

    public T ShowPopupUI<T>(UIKEY name) where T : UIPopup
    {
        if (name == UIKEY.NONE) return null;

        int index = GetHash(name);
        GameObject go = null;
        bool isExist = false;
        if (_popupKey[index].Equals(name))
        {
            go = _popupArray[(int)name].gameObject;
        }
        else
        {
            go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name.ToString()}Canvas");
            go.transform.SetParent(Root.transform);
            isExist = true;
        }
        go.SetActive(true);
        T sceneUI = Util.GetOrAddComponent<T>(go);
        if (sceneUI == null)
        {
            Debug.LogError("UIPopup is Null");
            return null;
        }
        sceneUI.Init();
        if (isExist)
        {
            // 아직 생성되지 않은 팝업일 경우
            // 키값 추가
            _popupKey[index] = name;
            _popupArray[index] = sceneUI;
        }

        return sceneUI;
    }
    public void ClosePopupUI(UIKEY name)
    {
        GameObject go = null;
        int index = 0;
        if (name == UIKEY.NONE)
        {
            //go = _popupArray[index].gameObject;
            return;
        }
        else
        {
            index = GetHash(name);
            if (_popupKey[index].Equals(name))
            {
                go = _popupArray[index].gameObject;
            }
        }
        if (go != null)
        {
            _order--;
            go.SetActive(false);
        }
    }
    public void CloseAllPopupUI()
    {
        for(int i = 0; i < (int)UIKEY.Max; i++)
        {
            if(_popupKey[i] != UIKEY.NONE)
                ClosePopupUI(_popupKey[i]);
        }
    }

    public void SetCanvas(GameObject go, bool sort = true)
    {
        Canvas canvas = Util.GetOrAddComponent<Canvas>(go);
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.overrideSorting = true;

        if (sort)
        {
            _order++;
            canvas.sortingOrder = _order;
        }
        else
        {
            canvas.sortingOrder = 0;
        }
    }
    public void ChangeAllCanvsRender(RenderMode mode , Camera camera = null)
    {
        for(int i = 0; i < (int)UIKEY.Max; i++)
        {
            if (_popupArray[i] != null)
            {
                Canvas canvas = _popupArray[i].GetComponent<Canvas>();
                canvas.renderMode = mode;
                if (mode == RenderMode.ScreenSpaceCamera)
                    canvas.worldCamera = camera;
            }
        }
    }
}
