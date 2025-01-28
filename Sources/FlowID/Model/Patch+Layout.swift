// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

public extension Patch {
    /// Recursive layout.
    ///
    /// - Returns: Height of all nodes in subtree.
    @discardableResult
    mutating func recursiveLayout(
        nodeID: UUID,
        at point: CGPoint,
        layout: LayoutConstants = LayoutConstants(),
        consumedNodeIndexes: Set<UUID> = [],
        nodePadding: Bool = false
    ) -> (aggregateHeight: CGFloat,
          consumedNodeIndexes: Set<UUID>)
    {
        var n = getNode(with: nodeID)
        //nodes[nodeIndex].position = point
        n!.position = point
        // XXX: super slow
        let incomingWires = wires.filter {
            $0.input.nodeID == nodeID
        }.sorted(by: { $0.input.portIndex < $1.input.portIndex })

        var consumedNodeIndexes = consumedNodeIndexes

        var height: CGFloat = 0
        for wire in incomingWires {
            let addPadding = wire == incomingWires.last
            let ni = wire.output.nodeID
            guard !consumedNodeIndexes.contains(ni) else { continue }
            let rl = recursiveLayout(nodeID: ni,
                                     at: CGPoint(x: point.x - layout.nodeWidth - layout.nodeSpacing,
                                                 y: point.y + height),
                                     layout: layout,
                                     consumedNodeIndexes: consumedNodeIndexes,
                                     nodePadding: addPadding)
            height = rl.aggregateHeight
            consumedNodeIndexes.insert(ni)
            consumedNodeIndexes.formUnion(rl.consumedNodeIndexes)
        }

        let nodeHeight = n!.rect(layout: layout).height
        let aggregateHeight = max(height, nodeHeight) + (nodePadding ? layout.nodeSpacing : 0)
        return (aggregateHeight: aggregateHeight,
                consumedNodeIndexes: consumedNodeIndexes)
    }

    /// Manual stacked grid layout.
    ///
    /// - Parameters:
    ///   - origin: Top-left origin coordinate.
    ///   - columns: Array of columns each comprised of an array of node indexes.
    ///   - layout: Layout constants.
    mutating func stackedLayout(at origin: CGPoint = .zero,
                                _ columns: [[NodeIndex]],
                                layout: LayoutConstants = LayoutConstants())
    {
        for column in columns.indices {
            let nodeStack = columns[column]
            var yOffset: CGFloat = 0

            let xPos = origin.x + (CGFloat(column) * (layout.nodeWidth + layout.nodeSpacing))
            for nodeIndex in nodeStack {
                nodes[nodeIndex].position = .init(
                    x: xPos,
                    y: origin.y + yOffset
                )

                let nodeHeight = nodes[nodeIndex].rect(layout: layout).height
                yOffset += nodeHeight
                if column != columns.indices.last {
                    yOffset += layout.nodeSpacing
                }
            }
        }
    }
}
