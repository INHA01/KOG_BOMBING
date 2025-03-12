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
        SceneManager.UnloadSceneAsync(currentScene);
        currentScene = sceneName;
        loading = LocalManagers.UI.ShowPopupUI<Loading>("LoadingCanvas");
        loading.LoadScene(sceneName);
    }
}
