// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Distinguish between patches using a unique ID or by name
///
/// Use SwiftUI's `onChange(of:)` to monitor changes, or use `NodeEditor.onNodeAdded`, etc.

public struct Patch: Equatable {
    public var id: UUID
    public var name: String
    public var nodes: [Node]
    public var wires: Set<Wire>

    public init(id: UUID, name: String, nodes: [Node], wires: Set<Wire>) {
        self.id = id
        self.name = name
        self.nodes = nodes
        self.wires = wires
    }
}
