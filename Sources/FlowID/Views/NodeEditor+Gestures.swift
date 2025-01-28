// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// State for all gestures.
    enum DragInfo {
        case wire(output: OutputID, offset: CGSize = .zero, hideWire: Wire? = nil)
        case node(id: UUID, offset: CGSize = .zero)
        case selection(rect: CGRect = .zero)
        case none
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func connect(_ output: OutputID, to input: InputID) {
        let wire = Wire(from: output, to: input)

        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            let result = w.input != wire.input
            if !result {
                wireRemoved(w)
            }
            return result
        }
        patch.wires.insert(wire)
        wireAdded(wire)
    }

    func attachedWire(inputID: InputID) -> Wire? {
        patch.wires.first(where: { $0.input == inputID })
    }

    func toLocal(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x / CGFloat(zoom), y: p.y / CGFloat(zoom)) - pan
    }

    func toLocal(_ sz: CGSize) -> CGSize {
        CGSize(width: sz.width / CGFloat(zoom), height: sz.height / CGFloat(zoom))
    }

#if os(macOS)
    var commandGesture: some Gesture {
        DragGesture(minimumDistance: 0).modifiers(.command).onEnded { drag in
            guard drag.distance < 5 else { return }

            let startLocation = toLocal(drag.startLocation)

            let hitResult = patch.hitTest(point: startLocation, layout: layout)
            switch hitResult {
            case .none:
                return
            case let .node(nodeID):
                if selection.contains(nodeID) {
                    selection.remove(nodeID)
                } else {
                    selection.insert(nodeID)
                }
            default: break
            }
        }
    }
#endif

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { drag, dragInfo, _ in

                let startLocation = toLocal(drag.startLocation)
                let location = toLocal(drag.location)
                let translation = toLocal(drag.translation)

                switch patch.hitTest(point: startLocation, layout: layout) {
                case .none:
                    dragInfo = .selection(rect: CGRect(a: startLocation,
                                                       b: location))
                case let .node(nodeID):
                    dragInfo = .node(id: nodeID, offset: translation)
                case let .output(nodeID, portIndex):
                    dragInfo = DragInfo.wire(output: OutputID(nodeID, portIndex), offset: translation)
                case let .input(noteID, portIndex):
                    print("FIX")
//                    let node = patch.nodes[nodeIndex]
//                    // Is a wire attached to the input?
//                    if let attachedWire = attachedWire(inputID: InputID(self.nodeID, portIndex)) {
//                        let offset = node.inputRect(input: portIndex, layout: layout).center
//                            - patch.nodes[attachedWire.output.nodeIndex].outputRect(
//                                output: attachedWire.output.portIndex,
//                                layout: layout
//                            ).center
//                            + translation
//                        dragInfo = .wire(output: attachedWire.output,
//                                         offset: offset,
//                                         hideWire: attachedWire)
//                    }
                }
            }
            .onEnded { drag in

                let startLocation = toLocal(drag.startLocation)
                let location = toLocal(drag.location)
                let translation = toLocal(drag.translation)

                let hitResult = patch.hitTest(point: startLocation, layout: layout)

                // Note that this threshold should be in screen coordinates.
                if drag.distance > 5 {
                    switch hitResult {
                    case .none:
                        let selectionRect = CGRect(a: startLocation, b: location)
                        selection = self.patch.selected(
                            in: selectionRect,
                            layout: layout
                        )
                    case let .node(nodeID):
                        patch.moveNode(
                            nodeID: nodeID,
                            offset: translation,
                            nodeMoved: self.nodeMoved
                        )
                        if selection.contains(nodeID) {
                            for id in selection where id != nodeID {
                                patch.moveNode(
                                    nodeID: id,
                                    offset: translation,
                                    nodeMoved: self.nodeMoved
                                )
                            }
                        }
                    case let .output(nodeID, portIndex):
                        let type = PortType.signal
                        //let type = patch.nodes[nodeIndex].outputs[portIndex].type
                        if let input = findInput(point: location, type: type) {
                            connect(OutputID(nodeID, portIndex), to: input)
                        }
                    case let .input(nodeID, portIndex):
                        let type = PortType.signal

                        //let type = patch.nodes[nodeIndex].inputs[portIndex].type
                        // Is a wire attached to the input?
                        if let attachedWire = attachedWire(inputID: InputID(nodeID, portIndex)) {
                            patch.wires.remove(attachedWire)
                            wireRemoved(attachedWire)
                            if let input = findInput(point: location, type: type) {
                                connect(attachedWire.output, to: input)
                            }
                        }
                    }
                } else {
                    // If we haven't moved far, then this is effectively a tap.
                    switch hitResult {
                    case .none:
                        selection = Set<UUID>()
                        print("no selection")
                    case let .node(nodeID):
                        selection = Set<UUID>([nodeID])
                        print("selected",selection.first?.uuid.0 )

                    default: break
                    }
                }
            }
    }
}

extension DragGesture.Value {
    @inlinable @inline(__always)
    var distance: CGFloat {
        startLocation.distance(to: location)
    }
}
