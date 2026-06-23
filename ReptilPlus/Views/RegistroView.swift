//
//  RegistroView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct RegistroView: View {
    @EnvironmentObject var auth: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var username = ""
    @State private var email = ""
    @State private var telefono = ""
    @State private var password = ""
    @State private var repetir = ""

    @State private var alertMsg = ""
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 24)

                Text("Crear cuenta")
                    .font(.title2)
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    TextField("Nombre", text: $nombre)
                        .textInputAutocapitalization(.words)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    TextField("Usuario", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    TextField("Teléfono", text: $telefono)
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Contraseña", text: $password)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Repetir contraseña", text: $repetir)
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                Button(action: onRegistrar) {
                    Text("Registrarse")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.2, green: 0.6, blue: 0.4), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Registro")
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK") {
                if auth.usuarioActual != nil { dismiss() }
            }
        } message: {
            Text(alertMsg)
        }
    }

    private func onRegistrar() {
        guard password == repetir else {
            alertMsg = "Las contraseñas no coinciden."
            showAlert = true
            return
        }
        guard email.contains("@"), email.contains(".") else {
            alertMsg = "Email no válido."
            showAlert = true
            return
        }
        switch auth.registrar(username: username,
                              password: password,
                              nombre: nombre,
                              email: email,
                              telefono: telefono) {
        case .success:
            alertMsg = "Cuenta creada correctamente."
            showAlert = true
        case .failure(.usuarioDuplicado):
            alertMsg = "Ese nombre de usuario ya existe."
            showAlert = true
        case .failure(.emailDuplicado):
            alertMsg = "Ese email ya está registrado."
            showAlert = true
        case .failure(.datosInvalidos):
            alertMsg = "Rellena todos los campos obligatorios."
            showAlert = true
        case .failure(.ioError(let msg)):
            alertMsg = "No se pudo guardar: \(msg)"
            showAlert = true
        default:
            alertMsg = "Error inesperado."
            showAlert = true
        }
    }
}
