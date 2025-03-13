using System.Collections;
using UnityEngine;

using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class Loading : UIPopup
{
    public string nextScene;
    [SerializeField] Image loadingCircle;

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
            Managers.UI.ClosePopupUI("LoadingCanvas");
        };

        float time = Time.time + 1.0f; // 1 seconds term

        float elapsedTime = 0f;
        float finishTime = 3f;
        float k = 5f;

        while (!asyncLoad.isDone)
        {
            yield return null;
            {
                // 지수 함수로 fillAmount 계산
                float t = elapsedTime / finishTime;
                loadingCircle.fillAmount = 1 - Mathf.Exp(-k * t);
                elapsedTime += Time.deltaTime;

                if (loadingCircle.fillAmount >= 0.99f)
                {
                    if (asyncLoad.progress / 1.0f > 0.7f)
                    {
                        if (Time.time > time)
                        {
                            asyncLoad.allowSceneActivation = true;
                            yield break;
                        }
                    }
                    loadingCircle.fillAmount = 0;
                    elapsedTime = 0f;
                }
            }
        }
    }
}
