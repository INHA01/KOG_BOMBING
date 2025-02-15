using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerMaterialController : MonoBehaviour
{
	public List<GameObject> changeMaterialMeshs = new List<GameObject>();
	public List<Material> changeMaterials = new List<Material>();
	public List<Material> curMaterial = new List<Material>();
	[SerializeField] private Material hitMaterial;
	Coroutine hit;

	public void Init(List<GameObject> meshs, Material hitMaterial)
	{
		changeMaterialMeshs = meshs;
		this.hitMaterial = hitMaterial;
	}

	public void SetOtherTeamMaterial(List<Material> changeMaterials)
	{
		this.changeMaterials = changeMaterials;
		SetMaterialToHide();
		//hitMaterial = Managers.Resource.Load<Material>("Materials/HitHideMaterial");
		for ( int i = 0; i < changeMaterialMeshs.Count; i++ )
		{
			Renderer mesh = changeMaterialMeshs[i].GetComponent<Renderer>();
			mesh.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
		}
	}

	public void SetMaterialToHide()
	{
		int index = 0;
		for (int i = 0; i < changeMaterialMeshs.Count; i++)
		{
			Renderer skin = changeMaterialMeshs[i].GetComponent<Renderer>();
			if (skin == null) continue;

			Material[] currentMaterials = null;
			currentMaterials = skin.materials;
			Material[] changeMats = new Material[currentMaterials.Length];
			for (int j = 0; j < currentMaterials.Length; j++)
				changeMats[j] = changeMaterials[index++];
			skin.materials = changeMats;
		}
	}

	public void SaveCurrentMaterial()
	{
		for (int i = 0; i < changeMaterialMeshs.Count; i++)
		{
			Renderer skin = changeMaterialMeshs[i].GetComponent<Renderer>();
			Material[] currentMaterials = null;
			if (skin)
				currentMaterials = skin.materials;
			for (int j = 0; j < currentMaterials.Length; j++)
				curMaterial.Add(currentMaterials[j]);
		}
	}

	public void Hit()
	{
		if (hit != null)
			StopCoroutine(hit);
		hit = StartCoroutine(ChangeHitMaterial());
	}

	IEnumerator ChangeHitMaterial()
	{
		for (int i = 0; i < changeMaterialMeshs.Count; i++)
		{
			Renderer skin = changeMaterialMeshs[i].GetComponent<Renderer>();
			if (!skin) yield break;
			Material[] currentMaterials = null;

			currentMaterials = skin.materials;
			for (int j = 0; j < currentMaterials.Length; j++)
				currentMaterials[j] = hitMaterial;
			skin.materials = currentMaterials;
		}
		yield return new WaitForSeconds(0.05f);

		int index = 0;
		for (int i = 0; i < changeMaterialMeshs.Count; i++)
		{
			Renderer skin = changeMaterialMeshs[i].GetComponent<Renderer>();
			Material[] currentMaterials = null;
			currentMaterials = skin.materials;
			Material[] changeMats = new Material[currentMaterials.Length];

			for (int j = 0; j < currentMaterials.Length; j++)
				changeMats[j] = curMaterial[index++];

			skin.materials = changeMats;
		}
		hit = null;
	}
}
