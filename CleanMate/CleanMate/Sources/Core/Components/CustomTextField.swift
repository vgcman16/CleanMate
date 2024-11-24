import SwiftUI

struct CustomTextField: View {
    @Binding private(set) var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(autocapitalization)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(
            text: .constant(""),
            placeholder: "Email",
            icon: "envelope",
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            autocapitalization: .none
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
