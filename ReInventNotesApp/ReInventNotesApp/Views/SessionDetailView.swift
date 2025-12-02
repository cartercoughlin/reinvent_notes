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
    
    var body: some View {
        VStack {
            // Notes Content
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(session.content) { element in
                        NoteElementView(element: element, session: session)
                            .environmentObject(themeManager)
                            .environmentObject(notesManager)
                    }
                }
                .padding()
            }
            
            // Input Controls (outside List)
            VStack(spacing: 16) {
                if showingTextInput {
                    HStack {
                        TextField("Type your note...", text: $newText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(themeManager.theme.cardBackground)
                            .cornerRadius(8)
                            .focused($isTextFieldFocused)
                        
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
        .onTapGesture {
            if showingTextInput && !isTextFieldFocused {
                showingTextInput = false
                newText = ""
                isTextInputActive = false
            }
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
    }
}

struct NoteElementView: View {
    let element: NoteElement
    let session: SessionNote
    @EnvironmentObject var themeManager: ReInventThemeManager
    @EnvironmentObject var notesManager: NotesManager
    @State private var isEditing = false
    @State private var editText = ""
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @FocusState private var isEditFieldFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timestamp
            Text(timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundColor(themeManager.theme.secondaryTextColor)
                .frame(width: 50, alignment: .leading)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                switch element {
                case .text(let textElement):
                    if isEditing {
                        HStack {
                            TextField("Edit text...", text: $editText, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                                .background(themeManager.theme.backgroundColor)
                                .cornerRadius(6)
                                .focused($isEditFieldFocused)
                            
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
                        Text(textElement.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                editText = textElement.content
                                isEditing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isEditFieldFocused = true
                                }
                            }
                    }
                
                case .photo(let photoElement):
                    if let image = UIImage(data: photoElement.imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        
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
                }
            }
        }
        .padding()
        .background(themeManager.theme.cardBackground)
        .cornerRadius(12)
        .offset(dragOffset)
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .shadow(radius: isDragging ? 8 : 0)
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture())
                .onChanged { value in
                    switch value {
                    case .second(true, let drag):
                        isDragging = true
                        if let drag = drag {
                            dragOffset = drag.translation
                        }
                    default:
                        break
                    }
                }
                .onEnded { value in
                    switch value {
                    case .second(true, let drag):
                        if let drag = drag {
                            // Check for swipe to delete
                            if abs(drag.translation.width) > 100 {
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
    }
    
    private var timestamp: Date {
        switch element {
        case .text(let textElement): return textElement.timestamp
        case .photo(let photoElement): return photoElement.timestamp
        case .drawing(let drawingElement): return drawingElement.timestamp
        }
    }
}