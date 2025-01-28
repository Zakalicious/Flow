import FlowID
import SwiftUI

func simplePatch() -> Patch {
    let generator = Node(name: "generator", id: UUID(), titleBarColor: Color.cyan, outputs: ["out"])
    let processor = Node(name: "processor", id: UUID(), titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
    let mixer = Node(name: "mixer", id: UUID(), titleBarColor: Color.gray, inputs: ["in1", "in2"], outputs: ["out"])
    let output = Node(name: "output", id: UUID(), titleBarColor: Color.purple, inputs: ["in"])

    let nodes = [generator, processor, output]

    let wires = Set([
        Wire(from: OutputID(generator.id, 0), to: InputID(processor.id, 0)),
        Wire(from: OutputID(processor.id, 0), to: InputID(output.id, 0))])

    var patch = Patch(nodes: nodes, wires: wires)
    patch.recursiveLayout(nodeIndex: nodes.count-1, at: CGPoint(x: 800, y: 50))
    return patch
}

struct ContentView: View {
    @State var patch = simplePatch()
    @State var selection = Set<UUID>()

    func addNode() {
        let newNode = Node(name: "processor", id: UUID(), titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
        patch.nodes.append(newNode)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NodeEditor(patch: $patch, selection: $selection)
            Button("Add Node", action: addNode).padding()
        }
    }
}


#Preview {
    ContentView()
}
