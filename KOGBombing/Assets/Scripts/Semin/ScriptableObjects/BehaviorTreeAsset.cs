using Semin;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.Antlr3.Runtime.Tree;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

[CreateAssetMenu(fileName = "Behavior Tree", menuName = "Scriptable Object/Behavior Tree", order = int.MaxValue)]
public class BehaviorTreeAsset : ScriptableObject
{
	public Node rootNode;
	[HideInInspector] public INode.ENodeState state = INode.ENodeState.Running;
	public List<Node> nodes = new List<Node>();
	GameObject target;

	public void SetTarget(GameObject target)
	{
		this.target = target;
		rootNode.SetTarget(target);
		//rootNode.SetTarget(target);
	}

	public INode.ENodeState Operate()
	{
		return rootNode.Evaluate();
	}

	public Node CreateNode(System.Type type)
	{
		Node node = null;
        if (typeof(Node).IsAssignableFrom(type))
        {
            node = ScriptableObject.CreateInstance(type) as Node;
            if (node != null)
            {
                node.name = type.Name;
				node.guid = GUID.Generate().ToString();

				Undo.RecordObject(this, "Behavior Tree (Create Node)");
				nodes.Add(node);

				if (Application.isPlaying)
				{
					AssetDatabase.AddObjectToAsset(node, this);
				}
            }
            else
            {
                Debug.LogError("Node 인스턴스 생성 실패");
            }
        }
		Undo.RegisterCreatedObjectUndo(node, "Behavior Tree (Create Node)");
		return node;
	}

	public void DeleteNode(Node node)
	{
		Undo.RecordObject(this, "Behavior Tree (DeleteNode)");
		nodes.Remove(node);
		//AssetDatabase.RemoveObjectFromAsset(node);
		Undo.DestroyObjectImmediate(node);
		AssetDatabase.SaveAssets();
	}

	public void AddChild(Node parent, Node child)
	{
		DecoratorNode decorator = parent as DecoratorNode; 
		if (decorator)
		{
			Undo.RecordObject(decorator, "Behavior Tree (Add Child)");
			decorator.SetChild(child);
			EditorUtility.SetDirty(decorator);
			return;
		}

		RootNode root = parent as RootNode;
		if (root)
		{
			Undo.RecordObject(root, "Behavior Tree (Add Child)");
			root.child = child;
			EditorUtility.SetDirty(root);
			return;
		}

		CompositeNode composite = parent as CompositeNode;
		if (composite)
		{
			Undo.RecordObject(composite, "Behavior Tree (Add Child)");
			composite.AddChild(child);
			EditorUtility.SetDirty(composite);
		}
	}

	public void RemoveChild(Node parent, Node child)
	{
		DecoratorNode decorator = parent as DecoratorNode;
		if (decorator)
		{
			Undo.RecordObject(decorator, "Behavior Tree (Remove Child)");
			decorator.SetChild(null);
			EditorUtility.SetDirty(decorator);
			return;
		}

		RootNode root = parent as RootNode;
		if (root)
		{
			Undo.RecordObject(root, "Behavior Tree (Remove Child)");
			root.child = null;
			EditorUtility.SetDirty(root);
			return;
		}

		CompositeNode composite = parent as CompositeNode;
		if (composite)
		{
			Undo.RecordObject(composite, "Behavior Tree (Remove Child)");
			composite.RemoveChild(child);
			EditorUtility.SetDirty(composite);
		}
	}

	public List<Node> GetChildren(Node parent)
	{
		List<Node> children = new List<Node>();
		DecoratorNode decorator = parent as DecoratorNode;
		if (decorator && decorator.GetChild() != null)
			children.Add(decorator.GetChild());


		RootNode root = parent as RootNode;
		if (root && root.child != null)
			children.Add(root.child);


		CompositeNode composite = parent as CompositeNode;
		if (composite)
			return composite.GetChildren();

		return children;
	}

	public void Traverse(Node node, System.Action<Node> visiter)
	{
		if (node)
		{
			visiter.Invoke(node);
			var children = GetChildren(node);
			children.ForEach((n) => Traverse(n, visiter));
		}

	}

	public BehaviorTreeAsset Clone()
	{
		BehaviorTreeAsset tree = Instantiate(this);
		tree.rootNode = tree.rootNode.Clone();
		tree.nodes = new List<Node>();
		Traverse(tree.rootNode, (n) =>
		{
			tree.nodes.Add(n);
		});
		return tree;
	}
}
