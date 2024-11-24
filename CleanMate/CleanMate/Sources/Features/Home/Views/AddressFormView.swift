import SwiftUI

struct AddressFormView: View {
    @Binding var selectedAddress: Address?
    @Binding var isPresented: Bool
    
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var country = "United States"
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Address Details") {
                    TextField("Street Address", text: $street)
                        .textContentType(.streetAddressLine1)
                    
                    TextField("City", text: $city)
                        .textContentType(.addressCity)
                    
                    TextField("State", text: $state)
                        .textContentType(.addressState)
                    
                    TextField("ZIP Code", text: $zipCode)
                        .textContentType(.postalCode)
                        .keyboardType(.numberPad)
                    
                    TextField("Country", text: $country)
                        .textContentType(.countryName)
                }
            }
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAddress()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveAddress() {
        guard validateFields() else { return }
        
        selectedAddress = Address(
            street: street,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country
        )
        
        isPresented = false
    }
    
    private func validateFields() -> Bool {
        if street.isEmpty {
            errorMessage = "Please enter street address"
            showError = true
            return false
        }
        
        if city.isEmpty {
            errorMessage = "Please enter city"
            showError = true
            return false
        }
        
        if state.isEmpty {
            errorMessage = "Please enter state"
            showError = true
            return false
        }
        
        if zipCode.isEmpty {
            errorMessage = "Please enter ZIP code"
            showError = true
            return false
        }
        
        if !zipCode.allSatisfy({ $0.isNumber }) {
            errorMessage = "ZIP code should contain only numbers"
            showError = true
            return false
        }
        
        return true
    }
}

struct AddressCard: View {
    let address: Address
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(address.street)
                .font(.headline)
            
            Text("\(address.city), \(address.state) \(address.zipCode)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(address.country)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AddressFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddressFormView(
            selectedAddress: .constant(nil),
            isPresented: .constant(true)
        )
    }
}
