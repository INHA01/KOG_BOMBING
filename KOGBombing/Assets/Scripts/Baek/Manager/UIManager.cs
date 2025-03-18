using BAEK;
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
    public List<UIPopup> _popupList = new List<UIPopup>();
    //key
    public List<UIKEY> _popupKey = new List<UIKEY>();
    public void Init()
    {
        _popupKey.Clear();
        for (int i = 0; i < (int)UIKEY.Max; i++)
        {
            _popupKey.Add(UIKEY.NONE);
        }
    }
    int GetHash(UIKEY key)
    {
        return key.GetHashCode() % (int)UIKEY.Max;
    }

    public T GetPopupUI<T>(UIKEY name) where T : UIPopup
    {
        int index = GetHash(name);
        if (_popupKey[index] != UIKEY.NONE || _popupKey[index].Equals(name))
        {
            return _popupList[index].GetComponent<T>();
        }
        T popup = ShowPopupUI<T>(name);
        if (popup != null)
            return popup.GetComponent<T>();
        return default;
    }

    public T ShowPopupUI<T>(UIKEY name) where T : UIPopup
    {
        int index = GetHash(name);
        GameObject go = null;
        bool isExist = false;
        if (_popupKey[index] == UIKEY.NONE || !_popupKey[index].Equals(name))
        {
            go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name.ToString()}Canvas");
            go.transform.SetParent(Root.transform);
            isExist = true;
        }
        else
        {
            go = _popupList[index].gameObject;
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
            _popupList.Add(sceneUI);
            _popupKey[index] = name;
        }

        return sceneUI;
    }
    public void ClosePopupUI(UIKEY name = UIKEY.NONE)
    {
        if (_popupList.Count == 0) return;
        GameObject go = null;
        if (name == UIKEY.NONE)
        {
            go = _popupList.Last().gameObject;
        }
        else
        {
            int index = GetHash(name);
            if (_popupKey[index].Equals(name))
            {
                go = _popupList[index].gameObject;
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
        for(int i = 0; i < _popupList.Count; i++)
        {
            ClosePopupUI();
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
    public void ChangeAllCanvsRender(RenderMode mode)
    {
        //foreach (var popup in _popupDictionary)
        //{
        //    Canvas canvas = popup.Value.GetComponent<Canvas>();
        //    canvas.renderMode = mode;
        //    if(mode == RenderMode.ScreenSpaceCamera)
        //        canvas.worldCamera = Managers.CamData.GetCamera(ECameraType.EFFECTCAMERA).GetComponent<Camera>();
        //}
    }
}
