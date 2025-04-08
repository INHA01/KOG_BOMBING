using BAEK;
using Orpul1;
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
    UIPopup[] _popupArray = new UIPopup[(int)UIKEY.Max];

    public void Init()
    {
        _order = 0;
    }


    public T GetPopupUI<T>(UIKEY name) where T : UIPopup
    {
        if (name == UIKEY.NONE) return null;
        int index = (int)name;
        if(_popupArray[index] != null)
        {
            return _popupArray[index] as T;
        }
        return ShowPopupUI<T>(name);
    }

    public T ShowPopupUI<T>(UIKEY name) where T : UIPopup
    {
        if (name == UIKEY.NONE) return null;

        int index = (int)name;
        GameObject go = _popupArray[index]?.gameObject;
        if(go == null)
        {
            go = Managers.Resource.Instantiate(FactoryType.UI, (int)name, Root.transform);
            T sceneUI = Util.GetOrAddComponent<T>(go);
            sceneUI.Init();
            _popupArray[index] = sceneUI;
        }
        go.SetActive(true);
        
        return _popupArray[index] as T;
    }
    public void ClosePopupUI(UIKEY name)
    {
        if (name == UIKEY.NONE) return;
        int index = (int)name;
        GameObject go = _popupArray[index]?.gameObject;
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
            if (i == (int)UIKEY.CrossHair || i == (int)UIKEY.Emoticon) continue;
            if(i != (int)UIKEY.NONE)
                ClosePopupUI((UIKEY)i);
        }
        _order = 0;
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
                if (i == (int)UIKEY.CrossHair || i == (int)UIKEY.Emoticon) continue;
                Canvas canvas = _popupArray[i].GetComponent<Canvas>();
                canvas.renderMode = mode;
                if (mode == RenderMode.ScreenSpaceCamera)
                    canvas.worldCamera = camera;
            }
        }
    }
}
