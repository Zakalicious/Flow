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
        for node in nodes {
            let nodeID = node.id
            if let result = node.hitTest(nodeID: nodeID, point: point, layout: layout) {
                return result
            }
        }

        return nil
    }

    mutating func moveNode(
        nodeID: UUID,
        offset: CGSize,
        nodeMoved: NodeEditor.NodeMovedHandler
    ) {
        var i = getNodeIndex(with: nodeID)
            if !nodes[i].locked {
                //print(nodeID.uuid.0, "at", n!.position)
                nodes[i].position += offset
                nodeMoved(nodes[i], nodes[i].position)
                //print(n!.id.uuid.0, "to", n!.position)
                //for n2 in nodes { print(n2.position)}

            }
        
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<UUID> {
        var selection = Set<UUID>()

        for node in nodes {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(node.id)
            }
        }
        return selection
    }
    
    public func getNode(with id: UUID) -> Node? {
        for n in self.nodes {
            if n.id == id {
                return n
            }
        }
        return nil
    }
    
    public func getNodeIndex(with id: UUID) -> Int {
        for i in 0..<self.nodes.count {
            if nodes[i].id == id {
                return i
            }
        }
        return -1
    }
}
