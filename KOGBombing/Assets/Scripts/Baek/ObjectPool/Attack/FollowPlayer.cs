using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowPlayer : MonoBehaviour
{
    GameObject player;
    public void Init(GameObject player)
    {
        this.player = player;
    }
    private void FixedUpdate()
    {
        if (player == null)
            return;
        transform.position = player.transform.position;
    }
}
