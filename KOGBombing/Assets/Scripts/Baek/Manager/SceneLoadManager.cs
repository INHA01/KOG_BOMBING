using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoadManager 
{
    public string currentScene;
    Loading loading;
    public void Init()
    { 
        currentScene = "LoginScene";
        SceneManager.LoadScene("UIScene", LoadSceneMode.Additive);
        AsyncOperation async = SceneManager.LoadSceneAsync(currentScene, LoadSceneMode.Additive);
        async.completed += (AsyncOperation obj) => { SceneManager.SetActiveScene(SceneManager.GetSceneByName(currentScene));};
    }
    public void LoadScene(string sceneName)
    {
        AsyncOperation async = SceneManager.UnloadSceneAsync(currentScene);
        async.completed += (AsyncOperation obj) => 
        {
            // close all popup UI 잘 안되서 임시로 다 지워지게 코드 바꿈
            LocalManagers.UI.CloseAllPopupUI(); 
            loading = LocalManagers.UI.ShowPopupUI<Loading>("LoadingCanvas");
            loading.LoadScene(sceneName);
        };
        currentScene = sceneName;
    }
}
