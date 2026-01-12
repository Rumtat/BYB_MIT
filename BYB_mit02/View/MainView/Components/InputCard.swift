import SwiftUI
import PhotosUI

struct InputCard: View {
    let selectedType: ScanType
    @Binding var inputText: String
    @Binding var phoneDigits: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var bankMode: BankSearchMode
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let onPickPhotoChanged: () -> Void

    let onPaste: () -> Void
    let onImportFile: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.25), lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))

                Button(action: onPaste) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.title3)
                        .padding(12)
                }
            }
            .frame(height: fieldHeight)
            .overlay(alignment: .topLeading) {
                content
                    .padding(14)
            }
            .padding(.horizontal, 16)
        }
    }

    private var fieldHeight: CGFloat {
        switch selectedType {
        case .bank: return 140
        case .qr: return 120
        case .phone: return 86
        case .url, .text: return 140
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedType {
        case .phone:
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("0xxxxxxxxx", text: $phoneDigits)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: phoneDigits) { _, newValue in
                        let digits = newValue.filter { $0.isNumber }
                        phoneDigits = String(digits.prefix(10))
                    }
            }

        case .bank:
            VStack(alignment: .leading, spacing: 8) {
                Text("Account / PromptPay")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Search Mode", selection: $bankMode) {
                    Text("By Account").tag(BankSearchMode.byAccount)
                    Text("By Name").tag(BankSearchMode.byName)
                }
                .pickerStyle(.segmented)

                if bankMode == .byName {
                    VStack(spacing: 6) {
                        TextField("First Name", text: $firstName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                        TextField("Last Name", text: $lastName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }
                } else {
                    TextField("Account Number", text: $inputText)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: inputText) { _, newValue in
                            let digits = newValue.filter { $0.isNumber }
                            inputText = String(digits.prefix(12))
                        }
                }
            }

        case .url:
            VStack(alignment: .leading, spacing: 8) {
                Text("Link (English only)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $inputText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: inputText) { _, newValue in
                        let filtered = newValue.filter { $0.asciiValue.map { $0 >= 32 && $0 <= 126 } ?? false }
                        if filtered != newValue { inputText = filtered }
                    }
            }

        case .qr:
            VStack(alignment: .leading, spacing: 8) {
                Text("Image Scan")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("เลือกรูปภาพเพื่อสแกน")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                    }
                )
                .onChange(of: selectedPhotoItem) { _, _ in
                    onPickPhotoChanged()
                }
            }

        case .text:
            VStack(alignment: .leading, spacing: 10) {
                Text("Text / File")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextEditor(text: $inputText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                // TODO: Document picker
            }
        }
    }
}
