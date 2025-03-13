using Photon.Pun;
using Photon.Realtime;
using System;
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
	Coroutine dashCoroutine;
	[SerializeField, Range(0, 10f)] float activeTime;
	[SerializeField, Range(0, 10f)] float meshRefreshTime;
	public List<SkinnedMeshRenderer> skinnedMeshRenderers;
	PlayerData playerData;
	[SerializeField] Material dashMaterial;
	private List<GameObject> dashMeshs = new List<GameObject>();

	public void Init(List<GameObject> meshs, Material hitMaterial, PlayerData playerData)
	{
		changeMaterialMeshs = meshs;
		this.hitMaterial = hitMaterial;
		this.playerData = playerData;
	}

	private void Awake()
	{
		effectMaterial.skinnedMesh = skinnedMeshRenderers;
		PlayerBlackBoard blackBoard = GetComponent<PlayerBlackBoard>();
		if (blackBoard.characterType == Semin.CharacterType.Uni)
			PoolingToDashTrails();
	}

	private void PoolingToDashTrails()
	{
		GameObject parentObject = new GameObject();
		parentObject.name = "Dash Trails";

		for (int j = 0; j < (activeTime + 1) / meshRefreshTime; j++)
		{
			for (int i = 0; i < skinnedMeshRenderers.Count; i++)
			{
				GameObject gObj = new GameObject();
				gObj.name = skinnedMeshRenderers[i].name;
				gObj.transform.SetPositionAndRotation(skinnedMeshRenderers[i].transform.position, skinnedMeshRenderers[i].transform.rotation);

				Mesh mesh = new Mesh();
				MeshRenderer mr = gObj.AddComponent<MeshRenderer>();
				MeshFilter mf = gObj.AddComponent<MeshFilter>();
				skinnedMeshRenderers[i].BakeMesh(mesh);

				Material[] currentMaterials = null;
				currentMaterials = skinnedMeshRenderers[i].materials;
				List<Material> changeMats = new List<Material>();
				for (int z = 0; z < currentMaterials.Length; z++)
					changeMats.Add(dashMaterial);
				mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
				mr.SetMaterials(changeMats);
				mf.mesh = mesh;

				gObj.gameObject.SetActive(false);
				dashMeshs.Add(gObj);
				gObj.transform.parent = parentObject.transform;
			}
		}
	}

	private void Start()
	{
		StartCreateEffect();
	}

	public void StartCreateEffect()
	{
		effectMaterial.materializeDuration = 4f;
		effectMaterial.Start_in();
		visualEffect.SendEvent("in");
	}

	IEnumerator ActiveTrails(float time)
	{
		int j = 0;

		while (time > 0)
		{
			time -= meshRefreshTime;
			
			if (skinnedMeshRenderers == null) yield break;

			for (int i = 0; i <skinnedMeshRenderers.Count; i++)
			{
				if (i + j * skinnedMeshRenderers.Count >= dashMeshs.Count) yield break;

				GameObject gObj = dashMeshs[i + j * skinnedMeshRenderers.Count];
				MeshFilter mf;
				if (gObj == null)
				{
					gObj = new GameObject();
					dashMeshs.Add(gObj);

					MeshRenderer mr = gObj.AddComponent<MeshRenderer>();
					mf = gObj.AddComponent<MeshFilter>();
					Mesh mesh = new Mesh();

					mf.mesh = mesh;
					mr.material = dashMaterial;
				}
				gObj.transform.SetPositionAndRotation(skinnedMeshRenderers[i].transform.position, skinnedMeshRenderers[i].transform.rotation);
				mf = gObj.GetComponent<MeshFilter>();
				skinnedMeshRenderers[i].BakeMesh(mf.mesh);
				gObj.SetActive(true);
				StartCoroutine(HideToObject(1f, gObj));
			}
			j++;

			yield return new WaitForSeconds(meshRefreshTime);
		}
	}

	IEnumerator HideToObject(float time, GameObject gameObject)
	{
		yield return new WaitForSeconds(time);
		gameObject.SetActive(false);
	}

	public void SetOtherTeamMaterial(List<Material> changeMaterials, HpBar hpBar)
	{
		this.changeMaterials = changeMaterials;
		SetMaterialToHide();
		hitMaterial = Managers.Resource.Load<Material>("Materials/HitHideMaterial");
		for ( int i = 0; i < changeMaterialMeshs.Count; i++ )
		{
			Renderer mesh = changeMaterialMeshs[i].GetComponent<Renderer>();
			mesh.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
		}
		dashMaterial = Managers.Resource.Load<Material>("Materials/DashTrailMaterialToStencil");
		for (int i = 0; i < dashMeshs.Count; i++ )
		{
			Material[] currentMaterials = null;
			currentMaterials = dashMeshs[i].GetComponent<MeshRenderer>().materials;
			List<Material> changeMats = new List<Material>();
			for (int z = 0; z < currentMaterials.Length; z++)
				changeMats.Add(dashMaterial);
			dashMeshs[i].GetComponent<MeshRenderer>().SetMaterials(changeMats);
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
		playerData.pv.RPC("StartDashSkillEffect", RpcTarget.All);
	}

	[PunRPC]
	public void StartDashSkillEffect()
	{
		effectMaterial.materializeDuration = 1.5f;
		effectMaterial.Start_in();
		visualEffect.SendEvent("in");

		if (dashCoroutine != null)
			StopCoroutine(dashCoroutine);
		dashCoroutine = StartCoroutine(ActiveTrails(activeTime));
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
