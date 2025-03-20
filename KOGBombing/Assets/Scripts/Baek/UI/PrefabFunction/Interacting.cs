using System;
using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace BAEK
{
    public class Interacting : UIPopup
    {
        enum Guide
        {
            Guide,
            BombGuide,
            Max
        }
        [SerializeField] GameObject[] guides = new GameObject[(int)Guide.Max];
        [SerializeField] GameObject[] interactUIs = new GameObject[(int)InteractUI.Max];
        [SerializeField] Slider interactBar;
        [SerializeField] TextMeshProUGUI bombTime;

        Coroutine bombSetCoroutine;
        public void SwitchGuide(bool isBomb)
        {
            guides[(int)Guide.Guide].SetActive(!isBomb);
            guides[(int)Guide.BombGuide].SetActive(isBomb);
        }
        public void ActiveCanInteract(bool canInteract , InteractUI interactUI)
        {
            if(!canInteract)
                Interact(0);
            interactUIs[(int)interactUI].SetActive(canInteract);
            if (canInteract == false)
                interactUIs[(int)InteractUI.InteractBar].SetActive(canInteract);
        }
        public void Interact(float amount)
        {
			interactUIs[(int)InteractUI.InteractBar].SetActive(true);
            interactBar.value = amount;
		}
        public void SetTimeCount(float time)
        {
            bombTime.text = string.Format("{0:00}:{1:00}", (int)time, (int)((time - (int)time) * 100));
        }
        public void NotifyBombSet()
        {
            Managers.Sound.PlayUISound(EUiSoundType.BOMBLAUNCHED);
            interactUIs[(int)InteractUI.Time].SetActive(true);
            interactUIs[(int)InteractUI.BombSet].SetActive(true);
            interactUIs[(int)InteractUI.BombDefuse].SetActive(false);
            if(bombSetCoroutine != null)
                StopCoroutine(bombSetCoroutine);
            bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(true));
        }
        public void NotifyBombDefuse()
        {
            interactUIs[(int)InteractUI.Time].SetActive(false);
            interactUIs[(int)InteractUI.BombSet].SetActive(false);
            interactUIs[(int)InteractUI.BombDefuse].SetActive(true);

            if(bombSetCoroutine != null)
                StopCoroutine(bombSetCoroutine);
            bombSetCoroutine = StartCoroutine(NotifyBombSetCoroutine(false));
        }

        IEnumerator NotifyBombSetCoroutine(bool isSet)
        {
            GameObject bomb = isSet ? interactUIs[(int)InteractUI.BombSet] : interactUIs[(int)InteractUI.BombDefuse];
            Image bombImage = bomb.GetComponent<Image>();
            Color color = bombImage.color;
            float time = 0;
            float addValue = -0.01f;
            while (time <= 10)
            {
                yield return null;
                color.a += addValue;
                if(color.a <= 0 || color.a >= 1)
                {
                    addValue *= -1;
                }
                bombImage.color = color;
                time += Time.deltaTime;
            }
            bomb.SetActive(false);
        }
        public void ActiveFalseAll()
        {
            for (int i = 0; i < interactUIs.Length; i++)
                interactUIs[i].SetActive(false);
            for(int i = 0; i < guides.Length; i++)
                guides[i].SetActive(false);
        }
    }
}
