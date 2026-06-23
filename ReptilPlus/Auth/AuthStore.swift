//
//  AuthStore.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import Foundation

struct Usuario: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var password: String
    var email: String
    var nombre: String
    var telefono: String
    var createdAt: Date

    init(id: UUID = UUID(),
         username: String,
         password: String,
         email: String,
         nombre: String,
         telefono: String,
         createdAt: Date = Date()) {
        self.id = id
        self.username = username
        self.password = password
        self.email = email
        self.nombre = nombre
        self.telefono = telefono
        self.createdAt = createdAt
    }
}

private struct UsuariosData: Codable {
    var usuarios: [Usuario]
}

enum AuthError: Error {
    case credencialesInvalidas
    case usuarioDuplicado
    case emailDuplicado
    case datosInvalidos
    case ioError(String)
}

final class AuthStore: ObservableObject {
    @Published private(set) var usuarios: [Usuario] = []
    @Published var usuarioActual: Usuario? = nil

    private let fileName = "usuarios.json"

    init() {
        do {
            if let data = try? Data(contentsOf: documentosURL()) {
                try cargarDesdeData(data)
            } else if let urlBundle = Bundle.main.url(forResource: "usuarios", withExtension: "json") {
                let data = try Data(contentsOf: urlBundle)
                try cargarDesdeData(data)
                try guardarAData(data)
            } else {
                usuarios = [Usuario(username: "andrea",
                                    password: "1234",
                                    email: "andrea@reptilplus.app",
                                    nombre: "Andrea Guillén",
                                    telefono: "+34 600 000 001")]
                try persistir()
            }
        } catch {
            print("⚠️ Error cargando usuarios: \(error)")
            usuarios = [Usuario(username: "andrea",
                                password: "1234",
                                email: "andrea@reptilplus.app",
                                nombre: "Andrea Guillén",
                                telefono: "+34 600 000 001")]
        }
    }

    // Devuelve Bool para compatibilidad con LoginView
    @discardableResult
    func login(username: String, password: String) -> Bool {
        guard let u = usuarios.first(where: { $0.username.lowercased() == username.lowercased() }),
              u.password == password else {
            return false
        }
        usuarioActual = u
        return true
    }

    func registrar(username: String,
                   password: String,
                   nombre: String,
                   email: String,
                   telefono: String) -> Result<Usuario, AuthError> {

        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.datosInvalidos)
        }

        if usuarios.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return .failure(.usuarioDuplicado)
        }
        if usuarios.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            return .failure(.emailDuplicado)
        }

        let nuevo = Usuario(username: username,
                            password: password,
                            email: email,
                            nombre: nombre,
                            telefono: telefono)

        usuarios.append(nuevo)
        do {
            try persistir()
            usuarioActual = nuevo
            return .success(nuevo)
        } catch {
            return .failure(.ioError(error.localizedDescription))
        }
    }

    func logout() { usuarioActual = nil }

    private func persistir() throws {
        let wrapper = UsuariosData(usuarios: usuarios)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        let data = try enc.encode(wrapper)
        try guardarAData(data)
    }

    private func cargarDesdeData(_ data: Data) throws {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        let wrapper = try dec.decode(UsuariosData.self, from: data)
        self.usuarios = wrapper.usuarios
    }

    private func documentosURL() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(fileName)
    }

    private func guardarAData(_ data: Data) throws {
        try data.write(to: documentosURL(), options: [.atomic])
    }
}
