using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.VFX;

public class PlayerMaterialController : MonoBehaviour
{
	List<GameObject> changeMaterialMeshs = new List<GameObject>();
	List<Material> changeMaterials = new List<Material>();		// Hide Material
	List<Material> curMaterial = new List<Material>();
	[SerializeField] private Material hitMaterial;
	Coroutine hit;
	public VisualEffect visualEffect;
	public UNI_Materialize effectMaterial;


	public void Init(List<GameObject> meshs, Material hitMaterial)
	{
		changeMaterialMeshs = meshs;
		this.hitMaterial = hitMaterial;
	}

	private void Start()
	{
		effectMaterial.materializeDuration = 4f;
		effectMaterial.Start_in();
		visualEffect.SendEvent("in");
	}

	public void SetOtherTeamMaterial(List<Material> changeMaterials, HpBar hpBar)
	{
		this.changeMaterials = changeMaterials;
		SetMaterialToHide();
		hitMaterial = LocalManagers.Resource.Load<Material>("Materials/HitHideMaterial");
		for ( int i = 0; i < changeMaterialMeshs.Count; i++ )
		{
			Renderer mesh = changeMaterialMeshs[i].GetComponent<Renderer>();
			mesh.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
		}
	}

	public void SetLayerToMyPlayer()
	{
		for (int i = 0; i < changeMaterialMeshs.Count; i++)
			effectMaterial.layerMask = LayerMask.NameToLayer("MyPlayer");
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

	public void ChangeMaterialToDashSkill()
	{
		effectMaterial.materializeDuration = 1.5f;
		effectMaterial.Start_in();
		visualEffect.SendEvent("in");
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
