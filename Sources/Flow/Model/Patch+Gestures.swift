// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

extension Patch {
    enum HitTestResult {
        case node(UUID)
        case input(UUID, PortIndex)
        case output(UUID, PortIndex)
    }

    /// Hit test a point against the whole patch.
    func hitTest(point: CGPoint, layout: LayoutConstants) -> HitTestResult? {
        for (nodeIndex, node) in nodes.enumerated().reversed() {
            let nodeID = nodes[nodeIndex].id
            if let result = node.hitTest(nodeID: nodeID, point: point, layout: layout) {
                return result
            }
        }

        return nil
    }

    mutating func moveNode(
        nodeIndex: NodeIndex,
        offset: CGSize,
        nodeMoved: NodeEditor.NodeMovedHandler
    ) {
        if !nodes[nodeIndex].locked {
            nodes[nodeIndex].position += offset
            nodeMoved(nodeIndex, nodes[nodeIndex].position)
        }
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<UUID> {
        var selection = Set<UUID>()

        for (idx, node) in nodes.enumerated() {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(node.id)
            }
        }
        return selection
    }
}
