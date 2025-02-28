using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyPlayerFieldOfView : MonoBehaviour
{
    [SerializeField] PlayerData playerData;
    void Start()
    {
		if (!playerData.pv.IsMine)
            gameObject.SetActive(false);
	}
}
