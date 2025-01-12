using System.Collections;
using System.Collections.Generic;
using UnityEngine.UIElements;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEditor;
using System;
using Semin;
using static UnityEditor.Experimental.GraphView.GraphView;
using UnityEngine.Assertions.Must;
using Unity.VisualScripting.Antlr3.Runtime.Tree;
using System.Linq;
using UnityEditor.IMGUI.Controls;

public class BehaviorTreeView : GraphView
{
	public Action<NodeView> OnNodeSelected;
	public new class UxmlFactory : UxmlFactory<BehaviorTreeView, GraphView.UxmlTraits> { }
	SCBehaviorTree tree;
	public BehaviorTreeView()
	{
		Insert(0, new GridBackground());


		this.AddManipulator(new ContentZoomer());
		this.AddManipulator(new ContentDragger());
		this.AddManipulator(new SelectionDragger());
		this.AddManipulator(new RectangleSelector());
		
		var styleSheet = AssetDatabase.LoadAssetAtPath<StyleSheet>("Assets/Editor/BehaviorTreeEditor.uss");
		styleSheets.Add(styleSheet);
	}

	NodeView FindNodeView(Semin.Node node)
	{
		return GetNodeByGuid(node.guid) as NodeView;
	}

	internal void PopulateView(SCBehaviorTree tree)
	{
		this.tree = tree;

		graphViewChanged -= OnGraphViewChanged;
		DeleteElements(graphElements);
		graphViewChanged += OnGraphViewChanged;

		if (tree.rootNode == null)
		{
			tree.rootNode = tree.CreateNode(typeof(RootNode)) as RootNode;
			EditorUtility.SetDirty(tree);
			AssetDatabase.SaveAssets();
		}

		tree.nodes.ForEach(n => CreateNodeView(n));

		tree.nodes.ForEach(n =>
		{
			var children = tree.GetChild(n);
			children.ForEach(c =>
			{
				NodeView parentView = FindNodeView(n);
				NodeView childView = FindNodeView(c);

				Edge edge = parentView.output.ConnectTo(childView.input);
				AddElement(edge);
			});
		});
	}

	public override List<Port> GetCompatiblePorts(Port startPort, NodeAdapter nodeAdapter)
	{
		return ports.ToList().Where(endPort => 
		endPort.direction != startPort.direction &&
		endPort.node != startPort.node).ToList();
	}

	public GraphViewChange OnGraphViewChanged(GraphViewChange graphViewChange)
	{
		if (graphViewChange.elementsToRemove != null)
		{
			graphViewChange.elementsToRemove.ForEach(elem =>
			{
				NodeView nodeView = elem as NodeView;
				if (nodeView != null)
					tree.DeleteNode(nodeView.node);

				Edge edge = elem as Edge;
				if (edge != null)
				{
					NodeView parentView = edge.output.node as NodeView;
					NodeView childView = edge.input.node as NodeView;
					tree.RemoveChild(parentView.node, childView.node);
				}
			});
		}

		if (graphViewChange.edgesToCreate != null)
		{
			graphViewChange.edgesToCreate.ForEach(edge =>
			{
				NodeView parentView = edge.output.node as NodeView;
				NodeView childView = edge.input.node as NodeView;
				tree.AddChild(parentView.node, childView.node);
			});
		}

		return graphViewChange;
	}

	public override void BuildContextualMenu(ContextualMenuPopulateEvent evt)
	{
		//base.BuildContextualMenu(evt);
		{
			var types = TypeCache.GetTypesDerivedFrom<Semin.Node>();
            foreach (var type in types)
            {
				if (!type.IsAbstract)
					evt.menu.AppendAction($"[{type.BaseType.Name}] {type.Name}", (a) => CreateNode(type));
			}
		}
	}

	public void CreateNode(System.Type type)
	{
		Semin.Node node = tree.CreateNode(type);
		CreateNodeView(node);
	}

	void CreateNodeView(Semin.Node node)
	{
		NodeView nodeView = new NodeView(node);
		nodeView.OnNodeSelected = OnNodeSelected;
		AddElement(nodeView);
	}
}

