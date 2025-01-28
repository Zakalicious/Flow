// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import SwiftUI

public typealias NodeIndex = Int

/// Nodes are identified by id in ``Patch/nodes``. This is diffenent from the original fork.

public struct Node: Equatable {
    public var name: String
    public var id: UUID
    public var position: CGPoint
    public var titleBarColor: Color

    /// Is the node position fixed so it can't be edited in the UI?
    public var locked = false

    public var inputs: [Port]
    public var outputs: [Port]

    @_disfavoredOverload
    public init(name: String,
                id: UUID,
                position: CGPoint = .zero,
                titleBarColor: Color = Color.clear,
                locked: Bool = false,
                inputs: [Port] = [],
                outputs: [Port] = [])
    {
        self.name = name
        self.id = id
        self.position = position
        self.titleBarColor = titleBarColor
        self.locked = locked
        self.inputs = inputs
        self.outputs = outputs
    }

    public init(name: String,
                id: UUID,
                position: CGPoint = .zero,
                titleBarColor: Color = Color.clear,
                locked: Bool = false,
                inputs: [String] = [],
                outputs: [String] = [])
    {
        self.name = name
        self.id = id
        self.position = position
        self.titleBarColor = titleBarColor
        self.locked = locked
        self.inputs = inputs.map { Port(name: $0) }
        self.outputs = outputs.map { Port(name: $0) }
    }
}

