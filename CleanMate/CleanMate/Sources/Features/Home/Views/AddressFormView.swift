import SwiftUI

struct AddressFormView: View {
    @Binding var address: Address?
    @Environment(\.dismiss) private var dismiss
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var country = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("ZIP Code", text: $zipCode)
                        .keyboardType(.numberPad)
                    TextField("Country", text: $country)
                }
                
                Section {
                    Button("Save Address") {
                        saveAddress()
                    }
                    .disabled(!isValidForm)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !street.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zipCode.isEmpty &&
        !country.isEmpty
    }
    
    private func saveAddress() {
        address = Address(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country
        )
        dismiss()
    }
}

struct AddressFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddressFormView(address: .constant(nil))
    }
}
