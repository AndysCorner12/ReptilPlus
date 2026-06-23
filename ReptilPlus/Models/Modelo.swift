//
//  Modelo.swift
//  ReptilPlus
//
//  Created by Andrea Guillen on 16/1/26.
//

import Foundation

// MARK: - Enums

public enum SexoReptil: String, Codable, CaseIterable {
    case macho, hembra, desconocido
}

public enum EstadoSalud: String, Codable, CaseIterable {
    case saludable, observacion, enfermo, critico
}

public enum TipoTarea: String, Codable, CaseIterable {
    case alimentar, limpiar, veterinario, pesar, temperatura, humedad
}

// MARK: - Especie

public final class Especie: Codable, Identifiable, Hashable {
    public let id: UUID
    public var nombreComun: String
    public var nombreCientifico: String
    public var descripcion: String
    public var familia: String?
    public var tamanoPromedio: Float?
    public var esperanzaVida: Int?

    public init(
        id: UUID = UUID(),
        nombreComun: String,
        nombreCientifico: String,
        descripcion: String,
        familia: String? = nil,
        tamanoPromedio: Float? = nil,
        esperanzaVida: Int? = nil
    ) {
        self.id = id
        self.nombreComun = nombreComun
        self.nombreCientifico = nombreCientifico
        self.descripcion = descripcion
        self.familia = familia
        self.tamanoPromedio = tamanoPromedio
        self.esperanzaVida = esperanzaVida
    }

    public static func == (lhs: Especie, rhs: Especie) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Registro de Peso

public struct RegistroPeso: Codable, Identifiable {
    public let id: UUID
    public var peso: Float
    public var fecha: Date
    public var notas: String?

    public init(
        id: UUID = UUID(),
        peso: Float,
        fecha: Date = Date(),
        notas: String? = nil
    ) {
        self.id = id
        self.peso = peso
        self.fecha = fecha
        self.notas = notas
    }
}

// MARK: - Tarea

public final class Tarea: Codable, Identifiable {
    public let id: UUID
    public var tipo: TipoTarea
    public var descripcion: String
    public var fechaHora: Date
    public var completada: Bool
    public var prioridad: Int

    public init(
        id: UUID = UUID(),
        tipo: TipoTarea,
        descripcion: String,
        fechaHora: Date,
        completada: Bool = false,
        prioridad: Int = 3
    ) {
        self.id = id
        self.tipo = tipo
        self.descripcion = descripcion
        self.fechaHora = fechaHora
        self.completada = completada
        self.prioridad = prioridad
    }
}

// MARK: - Reptil

public final class Reptil: Codable, Identifiable {
    public let id: UUID
    public var nombre: String
    public var especieId: UUID
    public var fechaNacimiento: Date?
    public var pesoActual: Float
    public var longitudActual: Float
    public var sexo: SexoReptil
    public var estado: EstadoSalud
    public var fotoURL: String?
    public var notas: String?

    public init(
        id: UUID = UUID(),
        nombre: String,
        especieId: UUID,
        fechaNacimiento: Date? = nil,
        pesoActual: Float,
        longitudActual: Float,
        sexo: SexoReptil = .desconocido,
        estado: EstadoSalud = .saludable,
        fotoURL: String? = nil,
        notas: String? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.especieId = especieId
        self.fechaNacimiento = fechaNacimiento
        self.pesoActual = pesoActual
        self.longitudActual = longitudActual
        self.sexo = sexo
        self.estado = estado
        self.fotoURL = fotoURL
        self.notas = notas
    }
}

// MARK: - Colección de Reptiles

public final class ColeccionReptiles: Codable, ObservableObject {
    @Published public var reptiles: [Reptil]
    @Published public var especies: [Especie]

    enum CodingKeys: String, CodingKey {
        case reptiles, especies
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reptiles = try container.decodeIfPresent([Reptil].self, forKey: .reptiles) ?? []
        especies = try container.decodeIfPresent([Especie].self, forKey: .especies) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reptiles, forKey: .reptiles)
        try container.encode(especies, forKey: .especies)
    }

    public init(reptiles: [Reptil] = [], especies: [Especie] = []) {
        self.reptiles = reptiles
        self.especies = especies
    }

    public var cantidad: Int {
        reptiles.count
    }

    public func agregar(_ reptil: Reptil) {
        reptiles.append(reptil)
    }

    public func eliminar(id: UUID) {
        reptiles.removeAll { $0.id == id }
    }

    public func obtener(id: UUID) -> Reptil? {
        reptiles.first { $0.id == id }
    }

    public func especiePara(id: UUID) -> Especie? {
        especies.first { $0.id == id }
    }

    public func ordenadosPorNombre() -> [Reptil] {
        reptiles.sorted { $0.nombre < $1.nombre }
    }

    public func filtrarPorSexo(_ sexo: SexoReptil) -> [Reptil] {
        reptiles.filter { $0.sexo == sexo }
    }
}

// MARK: - Carga desde JSON

public enum JSONStore {
    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    public static func cargarEspecies(from data: Data) throws -> [Especie] {
        let wrapper = try decoder.decode(EspeciesWrapper.self, from: data)
        return wrapper.especies
    }

    public static func cargarReptiles(from data: Data) throws -> ColeccionReptiles {
        try decoder.decode(ColeccionReptiles.self, from: data)
    }
}

struct EspeciesWrapper: Codable {
    let especies: [Especie]
}

struct ReptilesWrapper: Codable {
    let reptiles: [Reptil]
}
