// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

public extension NodeEditor {
    /// Offset to apply to a node based on selection and gesture state.
    func offset(for node: Node) -> CGSize {
        if node.locked {
            return .zero
        }
        switch dragInfo {
        case let .node(id: id, offset: offset):
            if node.id == id {
                //print("offset", offset) // ok
                return offset
            }
            if selection.contains(id), selection.contains(node.id) {
                // Offset other selected node only if we're dragging the
                // selection.
                return offset
            }
        default:
            return .zero
        }
        return .zero
    }

    /// Search for inputs.
    func findInput(node: Node, point: CGPoint, type: PortType) -> PortIndex? {
        node.inputs.enumerated().first { portIndex, input in
            input.type == type && node.inputRect(input: portIndex, layout: layout).contains(point)
        }?.0
    }

    /// Search for an input in the whole patch.
    func findInput(point: CGPoint, type: PortType) -> InputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in patch.nodes.enumerated().reversed() {
            if let portIndex = findInput(node: node, point: point, type: type) {
                let nodeID = node.id
                return InputID(nodeID, portIndex)
            }
        }
        return nil
    }

    /// Search for outputs.
    func findOutput(node: Node, point: CGPoint) -> PortIndex? {
        node.outputs.enumerated().first { portIndex, _ in
            node.outputRect(output: portIndex, layout: layout).contains(point)
        }?.0
    }

    /// Search for an output in the whole patch.
    func findOutput(point: CGPoint) -> OutputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in patch.nodes.enumerated().reversed() {
            if let portIndex = findOutput(node: node, point: point) {
                let nodeID = node.id
                return OutputID(nodeID, portIndex)
            }
        }
        return nil
    }

    /// Search for a node which intersects a point.
    func findNode(point: CGPoint) -> NodeIndex? {
        // Search nodes in reverse to find nodes drawn on top first.
        patch.nodes.enumerated().reversed().first { _, node in
            node.rect(layout: layout).contains(point)
        }?.0
    }
}
