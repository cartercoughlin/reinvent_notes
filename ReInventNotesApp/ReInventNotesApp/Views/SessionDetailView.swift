import SwiftUI

struct SessionDetailView: View {
    let session: SessionNote
    @Binding var isTextInputActive: Bool
    @EnvironmentObject var notesManager: NotesManager
    @EnvironmentObject var themeManager: ReInventThemeManager
    @State private var showingCamera = false
    @State private var showingDrawing = false
    @State private var showingTextInput = false
    @State private var newText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var scrollToBottom = false
    @State private var expandedImage: UIImage?
    @State private var expandedDrawing: [DrawingPath]?

    var body: some View {
        VStack {
            // Notes Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(session.content) { element in
                            NoteElementView(
                                element: element,
                                session: session,
                                expandedImage: $expandedImage,
                                expandedDrawing: $expandedDrawing
                            )
                                .environmentObject(themeManager)
                                .environmentObject(notesManager)
                                .id(element.id)
                        }

                        // Add spacer at bottom to ensure content can scroll past input controls
                        Color.clear
                            .frame(height: 150)
                            .id("bottomSpacer")
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: session.content.count) {
                    // Auto-scroll to bottom when new content is added
                    if let lastElement = session.content.last {
                        withAnimation {
                            proxy.scrollTo(lastElement.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Controls (outside List)
            VStack(spacing: 16) {
                if showingTextInput {
                    HStack(alignment: .top) {
                        TextField("Type your note...", text: $newText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(themeManager.theme.cardBackground)
                            .cornerRadius(8)
                            .focused($isTextFieldFocused)
                            .lineLimit(5...10)

                        Button("Add") {
                            if !newText.isEmpty {
                                notesManager.addTextElement(to: session, content: newText)
                                newText = ""
                                showingTextInput = false
                                isTextInputActive = false
                            }
                        }
                        .disabled(newText.isEmpty)
                        .foregroundColor(themeManager.theme.primaryTextColor)
                    }
                    .padding()
                    .background(themeManager.theme.cardBackground)
                    .cornerRadius(12)
                } else {
                    Button("Tap to add text") {
                        showingTextInput = true
                        isTextInputActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isTextFieldFocused = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.theme.cardBackground.opacity(0.5))
                    .foregroundColor(themeManager.theme.secondaryTextColor)
                    .cornerRadius(12)
                }
                
                HStack(spacing: 20) {
                    Button(action: { showingCamera = true }) {
                        Label("Photo", systemImage: "camera")
                    }
                    .foregroundColor(themeManager.theme.primaryTextColor)
                    
                    Button(action: { showingDrawing = true }) {
                        Label("Draw", systemImage: "pencil.tip")
                    }
                    .foregroundColor(themeManager.theme.primaryTextColor)
                }
            }
            .padding()
            .background(themeManager.theme.backgroundColor)
        }
        .onChange(of: isTextFieldFocused) {
            isTextInputActive = isTextFieldFocused && showingTextInput
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(session: session)
                .environmentObject(notesManager)
        }
        .sheet(isPresented: $showingDrawing) {
            DrawingView(session: session)
                .environmentObject(notesManager)
                .environmentObject(themeManager)
        }
        .sheet(item: Binding(
            get: { expandedImage.map { ExpandedImageWrapper(image: $0) } },
            set: { expandedImage = $0?.image }
        )) { wrapper in
            ExpandedImageView(image: wrapper.image)
                .environmentObject(themeManager)
        }
        .sheet(item: Binding(
            get: { expandedDrawing.map { ExpandedDrawingWrapper(paths: $0) } },
            set: { expandedDrawing = $0?.paths }
        )) { wrapper in
            ExpandedDrawingView(paths: wrapper.paths)
                .environmentObject(themeManager)
        }
    }
}

struct NoteElementView: View {
    let element: NoteElement
    let session: SessionNote
    @Binding var expandedImage: UIImage?
    @Binding var expandedDrawing: [DrawingPath]?
    @EnvironmentObject var themeManager: ReInventThemeManager
    @EnvironmentObject var notesManager: NotesManager
    @State private var isEditing = false
    @State private var editText = ""
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @FocusState private var isEditFieldFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp - Drag handle area
            Text(timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundColor(themeManager.theme.secondaryTextColor)
                .frame(width: 50, alignment: .leading)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture())
                        .onChanged { value in
                            print("Gesture changed: \(value)")
                            switch value {
                            case .second(true, let drag):
                                isDragging = true
                                if let drag = drag {
                                    dragOffset = drag.translation
                                    print("Dragging: \(drag.translation)")
                                }
                            default:
                                break
                            }
                        }
                        .onEnded { value in
                            print("Gesture ended: \(value)")
                            switch value {
                            case .second(true, let drag):
                                if let drag = drag {
                                    print("Drag ended with translation: \(drag.translation)")

                                    // Check for swipe to delete
                                    if abs(drag.translation.width) > 100 {
                                        print("Deleting element")
                                        notesManager.deleteNoteElement(in: session, elementId: element.id)
                                        isDragging = false
                                        dragOffset = .zero
                                        return
                                    }

                                    // Check for reorder
                                    let dragDistance = abs(drag.translation.height)
                                    if dragDistance > 50 {
                                        if let currentIndex = session.content.firstIndex(where: { $0.id == element.id }) {
                                            let newIndex = drag.translation.height > 0 ?
                                                min(currentIndex + 1, session.content.count - 1) :
                                                max(currentIndex - 1, 0)

                                            print("Reordering from \(currentIndex) to \(newIndex)")
                                            if newIndex != currentIndex {
                                                notesManager.reorderNoteElements(in: session, from: currentIndex, to: newIndex > currentIndex ? newIndex + 1 : newIndex)
                                            }
                                        }
                                    }
                                }
                            default:
                                break
                            }

                            isDragging = false
                            withAnimation(.spring()) {
                                dragOffset = .zero
                            }
                        }
                )

            // Content
            VStack(alignment: .leading, spacing: 8) {
                switch element {
                case .text(let textElement):
                    if isEditing {
                        HStack(alignment: .top) {
                            TextField("Edit text...", text: $editText, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(themeManager.theme.backgroundColor)
                                .cornerRadius(6)
                                .focused($isEditFieldFocused)
                                .lineLimit(5...10)

                            Button("Save") {
                                if !editText.isEmpty {
                                    notesManager.updateTextElement(in: session, elementId: element.id, newContent: editText)
                                    isEditing = false
                                } else {
                                    // Delete if text is empty
                                    notesManager.deleteNoteElement(in: session, elementId: element.id)
                                }
                            }
                            .foregroundColor(themeManager.theme.primaryTextColor)
                        }
                    } else {
                        Button(action: {
                            editText = textElement.content
                            isEditing = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isEditFieldFocused = true
                            }
                        }) {
                            Text(textElement.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(themeManager.theme.primaryTextColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                case .photo(let photoElement):
                    if let image = UIImage(data: photoElement.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .onTapGesture {
                                expandedImage = image
                            }

                        if !photoElement.caption.isEmpty {
                            Text(photoElement.caption)
                                .font(.caption)
                                .foregroundColor(themeManager.theme.secondaryTextColor)
                        }
                    }

                case .drawing(let drawingElement):
                    DrawingDisplayView(paths: drawingElement.paths)
                        .frame(height: 150)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onTapGesture {
                            expandedDrawing = drawingElement.paths
                        }
                }
            }
        }
        .padding()
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .offset(dragOffset)
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .shadow(radius: isDragging ? 8 : 0)
    }
    
    private var timestamp: Date {
        switch element {
        case .text(let textElement): return textElement.timestamp
        case .photo(let photoElement): return photoElement.timestamp
        case .drawing(let drawingElement): return drawingElement.timestamp
        }
    }
}

// Wrapper structs for sheet presentation
struct ExpandedImageWrapper: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ExpandedDrawingWrapper: Identifiable {
    let id = UUID()
    let paths: [DrawingPath]
}

// Expanded image view
struct ExpandedImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ReInventThemeManager
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.backgroundColor
                    .ignoresSafeArea()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.primaryTextColor)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// Expanded drawing view
struct ExpandedDrawingView: View {
    let paths: [DrawingPath]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ReInventThemeManager

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.theme.backgroundColor
                    .ignoresSafeArea()

                DrawingDisplayView(paths: paths)
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.primaryTextColor)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}