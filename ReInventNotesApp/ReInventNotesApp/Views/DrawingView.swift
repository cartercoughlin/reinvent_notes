import SwiftUI

struct DrawingView: View {
    let session: SessionNote
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var paths: [DrawingPath] = []
    @State private var currentPath = DrawingPath(points: [], color: "orange", width: 3.0)
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isErasing = false
    @State private var isPanning = false
    @State private var lastPanOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            VStack {
                // Drawing Canvas
                Canvas { context, size in
                    for path in paths {
                        var cgPath = Path()
                        if let firstPoint = path.points.first {
                            cgPath.move(to: firstPoint)
                            for point in path.points.dropFirst() {
                                cgPath.addLine(to: point)
                            }
                        }
                        
                        context.stroke(
                            cgPath,
                            with: .color(colorFromString(path.color)),
                            lineWidth: path.width * scale
                        )
                    }
                    
                    // Current path being drawn
                    if !currentPath.points.isEmpty {
                        var cgPath = Path()
                        if let firstPoint = currentPath.points.first {
                            cgPath.move(to: firstPoint)
                            for point in currentPath.points.dropFirst() {
                                cgPath.addLine(to: point)
                            }
                        }
                        
                        context.stroke(
                            cgPath,
                            with: .color(colorFromString(currentPath.color)),
                            lineWidth: currentPath.width * scale
                        )
                    }
                }
                .background(Color(.systemGray6))
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if isPanning {
                                    offset = CGSize(
                                        width: lastPanOffset.width + value.translation.width,
                                        height: lastPanOffset.height + value.translation.height
                                    )
                                } else if isErasing {
                                    let location = CGPoint(
                                        x: (value.location.x - offset.width) / scale,
                                        y: (value.location.y - offset.height) / scale
                                    )
                                    paths.removeAll { path in
                                        path.points.contains { point in
                                            let distance = sqrt(pow(point.x - location.x, 2) + pow(point.y - location.y, 2))
                                            return distance < 20
                                        }
                                    }
                                } else {
                                    let adjustedLocation = CGPoint(
                                        x: (value.location.x - offset.width) / scale,
                                        y: (value.location.y - offset.height) / scale
                                    )
                                    currentPath.points.append(adjustedLocation)
                                }
                            }
                            .onEnded { _ in
                                if isPanning {
                                    lastPanOffset = offset
                                } else if !isErasing && !currentPath.points.isEmpty {
                                    paths.append(currentPath)
                                    currentPath = DrawingPath(points: [], color: currentPath.color, width: currentPath.width)
                                }
                            },
                        
                        MagnificationGesture()
                            .onChanged { value in
                                scale = max(0.5, min(3.0, value))
                            }
                    )
                )
                
                // Drawing Controls
                VStack {
                    HStack {
                        Button(isPanning ? "Draw" : "Pan") {
                            isPanning.toggle()
                            if isPanning {
                                isErasing = false
                            }
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                        
                        Button(isErasing ? "Draw" : "Erase") {
                            isErasing.toggle()
                            if isErasing {
                                isPanning = false
                            }
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                        
                        Button("Clear") {
                            paths.removeAll()
                            currentPath.points.removeAll()
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                        
                        Spacer()
                        
                        Button("Reset Zoom") {
                            scale = 1.0
                            offset = .zero
                            lastPanOffset = .zero
                        }
                        .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                    }
                    
                    if !isErasing && !isPanning {
                        HStack {
                            Text("Colors:")
                            ForEach(["orange", "blue", "black", "red"], id: \.self) { color in
                                Circle()
                                    .fill(colorFromString(color))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: currentPath.color == color ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        currentPath.color = color
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Draw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !paths.isEmpty {
                            notesManager.addDrawingElement(to: session, paths: paths)
                        }
                        dismiss()
                    }
                    .disabled(paths.isEmpty)
                    .buttonStyle(RainbowBorderButtonStyle(theme: themeManager.theme))
                }
            }
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return themeManager.theme.accentColor
        case "blue": return Color.blue
        case "red": return .red
        default: return .black
        }
    }
}

struct DrawingDisplayView: View {
    let paths: [DrawingPath]
    
    var body: some View {
        Canvas { context, size in
            for path in paths {
                var cgPath = Path()
                if let firstPoint = path.points.first {
                    cgPath.move(to: firstPoint)
                    for point in path.points.dropFirst() {
                        cgPath.addLine(to: point)
                    }
                }
                
                context.stroke(
                    cgPath,
                    with: .color(colorFromString(path.color)),
                    lineWidth: path.width
                )
            }
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "orange": return Color.orange
        case "blue": return Color.blue
        case "red": return .red
        default: return .black
        }
    }
}