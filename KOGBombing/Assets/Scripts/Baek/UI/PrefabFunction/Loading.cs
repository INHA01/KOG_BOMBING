using System.Collections;
using UnityEngine;

using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class Loading : UIPopup
{
    public string nextScene;

    public void LoadScene(string sceneName)
    {
        nextScene = sceneName;
        StartCoroutine(LoadScene());
    }
    IEnumerator LoadScene()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(nextScene, LoadSceneMode.Additive);
        asyncLoad.allowSceneActivation = false;
        asyncLoad.completed += (AsyncOperation obj) =>
        {
            SceneManager.SetActiveScene(SceneManager.GetSceneByName(nextScene));
            Managers.UI.ClosePopupUI(BAEK.UIKEY.Loading);
        };

        float time = Time.time + 3.0f; // 3 seconds term


        while (!asyncLoad.isDone)
        {
            yield return null;
            {
                if (asyncLoad.progress / 1.0f > 0.7f)
                {
                    if (Time.time > time)
                    {
                        asyncLoad.allowSceneActivation = true;
                        yield break;
                    }
                }
            }
        }
    }
}
