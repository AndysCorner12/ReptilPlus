//
//  LoginView.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthStore
    @ObservedObject private var prefs = UserPreferences.shared
    @State private var username = ""
    @State private var password = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    @State private var logoOffset: CGFloat = -200
    @State private var fieldsOpacity = 0.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.6, blue: 0.4), Color(red: 0.1, green: 0.4, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .offset(y: logoOffset)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            logoOffset = 0
                        }
                        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                            fieldsOpacity = 1.0
                        }
                    }

                Text("Reptil Plus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Gestión de cuidados de reptiles")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                VStack(spacing: 12) {
                    TextField("Usuario", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    Button {
                        intentarLogin()
                    } label: {
                        Text("Iniciar Sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.4))
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: RegistroView()) {
                        Text("¿No tienes cuenta? Regístrate")
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, 40)
                .opacity(fieldsOpacity)
            }
        }
        .alert(alertMsg, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    func intentarLogin() {
        if username.isEmpty || password.isEmpty {
            alertMsg = "Por favor, completa todos los campos"
            showAlert = true
            return
        }

        if auth.login(username: username, password: password) {
            // Guardar en UserDefaults
            prefs.login(username: username, userId: auth.usuarioActual?.id.uuidString ?? "")
            alertMsg = "¡Bienvenido!"
            showAlert = true
        } else {
            alertMsg = "Usuario o contraseña incorrectos"
            showAlert = true
        }
    }
}
