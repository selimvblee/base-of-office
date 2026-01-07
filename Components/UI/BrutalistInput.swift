import SwiftUI

/// Base of Office - Neo-Brutalism Custom Input
/// Kalın siyah kenarlıklar ile
struct BrutalistTextField: View {
    // MARK: - Properties
    
    let placeholder: String
    let icon: String?
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    
    @FocusState private var isFocused: Bool
    @State private var showPassword = false
    
    // MARK: - Initializers
    
    init(
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(AppTypography.body(weight: AppTypography.medium))
                    .foregroundColor(isFocused ? AppColors.textPrimary : AppColors.textSecondary)
                    .frame(width: 20)
            }
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(AppTypography.body())
                    .foregroundColor(AppColors.textPrimary)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppTypography.body())
                    .foregroundColor(AppColors.textPrimary)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if isSecure {
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(AppTypography.body(weight: AppTypography.medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isFocused ? AppColors.textPrimary : AppColors.border,
                    lineWidth: isFocused ? 3 : 2
                )
        )
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Text Area (Multi-line)

struct BrutalistTextArea: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    
    @FocusState private var isFocused: Bool
    
    init(
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppTypography.body())
                    .foregroundColor(AppColors.textLight)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
            
            TextEditor(text: $text)
                .font(AppTypography.body())
                .foregroundColor(AppColors.textPrimary)
                .focused($isFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .scrollContentBackground(.hidden)
                .background(.white)
        }
        .frame(minHeight: minHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isFocused ? AppColors.textPrimary : AppColors.border,
                    lineWidth: isFocused ? 3 : 2
                )
        )
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Picker Field

struct BrutalistPicker<T: Hashable>: View {
    let title: String
    let icon: String?
    @Binding var selection: T
    let options: [T]
    let displayText: (T) -> String
    
    init(
        title: String,
        icon: String? = nil,
        selection: Binding<T>,
        options: [T],
        displayText: @escaping (T) -> String
    ) {
        self.title = title
        self.icon = icon
        self._selection = selection
        self.options = options
        self.displayText = displayText
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(AppTypography.body(weight: AppTypography.medium))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 20)
            }
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(displayText(option))
                        .tag(option)
                }
            }
            .pickerStyle(.menu)
            .font(AppTypography.body())
            .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.border, lineWidth: 2)
        )
        .cornerRadius(8)
    }
}

// MARK: - Tag Input (Multi-select chips)

struct BrutalistTagInput: View {
    let placeholder: String
    @Binding var tags: [String]
    @State private var currentInput = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Tags display
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 6) {
                            Text(tag)
                                .font(AppTypography.caption1(weight: AppTypography.medium))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                tags.removeAll { $0 == tag }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(AppTypography.caption1())
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.activityPurple)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColors.border, lineWidth: 2)
                        )
                        .cornerRadius(6)
                    }
                }
            }
            
            // Input field
            HStack {
                TextField(placeholder, text: $currentInput)
                    .font(AppTypography.body())
                    .foregroundColor(AppColors.textPrimary)
                    .onSubmit {
                        addTag()
                    }
                
                if !currentInput.isEmpty {
                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .font(AppTypography.body(weight: AppTypography.semiBold))
                            .foregroundColor(AppColors.successGreen)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.border, lineWidth: 2)
            )
            .cornerRadius(8)
        }
    }
    
    private func addTag() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            currentInput = ""
        }
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            BrutalistTextField(
                placeholder: "Email",
                icon: "envelope.fill",
                text: .constant("")
            )
            
            BrutalistTextField(
                placeholder: "Şifre",
                icon: "lock.fill",
                text: .constant(""),
                isSecure: true
            )
            
            BrutalistTextArea(
                placeholder: "Açıklama yazın...",
                text: .constant("")
            )
            
            BrutalistPicker(
                title: "Rol Seçin",
                icon: "person.fill",
                selection: .constant("Yönetici"),
                options: ["Yönetici", "Çalışan", "İş Ortağı"],
                displayText: { $0 }
            )
            
            BrutalistTagInput(
                placeholder: "Meslek ekle",
                tags: .constant(["Yazılımcı", "Tasarımcı"])
            )
        }
        .padding()
    }
    .background(AppColors.background)
}
