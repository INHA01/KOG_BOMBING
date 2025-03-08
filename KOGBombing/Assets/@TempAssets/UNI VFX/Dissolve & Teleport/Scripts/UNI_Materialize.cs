using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UNI_Materialize : MonoBehaviour
{
    public List<SkinnedMeshRenderer> skinnedMesh;
    public float materializeDuration = 4.0f;
    public LayerMask layerMask;

	private void Awake()
	{
		layerMask = LayerMask.NameToLayer("IgnoreDecals");
	}
	public void Start_in()
    {
        for (int i = 0; i < skinnedMesh.Count; i++)
            skinnedMesh[i].gameObject.layer = 0;
        StartCoroutine(MaterializeIn());
    }

    public void Start_out()
    {
        StartCoroutine(MaterializeOut());
    }

    IEnumerator MaterializeIn()
    {
        float m_step = 1 / (materializeDuration * 50);
        float m_in = 0;
        while (m_in < 1)
        {
            m_in += m_step;
            for (int i = 0; i < skinnedMesh.Count; i++)
            {
				Renderer skin = skinnedMesh[i].GetComponent<Renderer>();
				if (skin == null) continue;

				Material[] currentMaterials = null;
				currentMaterials = skin.materials;
				for (int j = 0; j < currentMaterials.Length; j++)
					currentMaterials[j].SetFloat("_Materialize", m_in);
			}
            yield return new WaitForSeconds(0.02f);
		}
        for (int i = 0; i < skinnedMesh.Count; i++)
            skinnedMesh[i].gameObject.layer = layerMask;
	}
    IEnumerator MaterializeOut()
    {
        float m_step = 1 / (materializeDuration * 50);
        float m_out = 1;
        while (m_out > 0)
        {
            m_out -= m_step;
			for (int i = 0; i < skinnedMesh.Count; i++)
			{
				Renderer skin = skinnedMesh[i].GetComponent<Renderer>();
				if (skin == null) continue;

				Material[] currentMaterials = null;
				currentMaterials = skin.materials;
				for (int j = 0; j < currentMaterials.Length; j++)
					currentMaterials[j].SetFloat("_Materialize", m_out);
			}
			yield return new WaitForSeconds(0.02f);
        }
    }
}
