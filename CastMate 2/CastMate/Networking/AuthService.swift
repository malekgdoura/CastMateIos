import Foundation

struct AuthService {
    private let client = APIClient()

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginBody(email: email, password: password)
        let response: AuthResponse = try await client.request("auth/login", method: .post, body: body)
        guard response.access_token != nil else {
            throw APIError.missingAccessToken
        }
        return response
    }

    @discardableResult
    func signupActor(from data: ActorSignUpData) async throws -> AuthResponse {
        let payload = ActorSignupBody(data: data)
        let response: AuthResponse = try await client.request("acteur/signup", method: .post, body: payload)
        if let token = response.access_token, !token.isEmpty {
            return response
        }
        return try await login(email: data.email, password: data.password)
    }

    @discardableResult
    func signupAgency(from data: AgencySignUpData) async throws -> AuthResponse {
        let payload = AgencySignupBody(data: data)
        let response: AuthResponse = try await client.request("agence/signup", method: .post, body: payload)
        if let token = response.access_token, !token.isEmpty {
            return response
        }
        return try await login(email: data.email, password: data.password)
    }

    func fetchCurrentUser(token: String) async throws -> UserInfo {
        try await client.request(
            "users/me",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
    }

    func fetchActorProfile(id: String, token: String) async throws -> ActorProfile {
        try await client.request(
            "acteur/\(id)",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
    }

    func updateActorProfile(id: String, token: String, body: ActorProfileUpdate) async throws -> ActorProfile {
        try await client.request(
            "acteur/\(id)",
            method: .patch,
            body: body,
            headers: ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
        )
    }

    func fetchCastings() async throws -> [CastingSummary] {
        try await client.request("castings", method: .get)
    }

    func fetchCastingDetail(id: String) async throws -> CastingDetail {
        try await client.request("castings/\(id)", method: .get)
    }
}

struct AuthResponse: Decodable {
    let access_token: String?
    let user: UserInfo?
}

private struct LoginBody: Encodable {
    let email: String
    let password: String
}

private struct ActorSignupBody: Encodable {
    let nom: String
    let prenom: String
    let email: String
    let motDePasse: String
    let tel: String
    let age: Int?
    let gouvernorat: String
    let experience: Int?
    let cvPdf: String?
    let centresInteret: [String]
    let photoProfil: String?
    let socialLinks: SocialLinks?

    init(data: ActorSignUpData) {
        self.nom = data.lastName
        self.prenom = data.firstName
        self.email = data.email
        self.motDePasse = data.password
        self.tel = data.phone
        self.age = Int(data.age)
        self.gouvernorat = data.government
        self.experience = Int(data.yearsOfExperience)
        self.cvPdf = data.cvURL?.absoluteString
        self.centresInteret = Array(data.interests)
        self.photoProfil = data.profileImageBase64
        if data.hasSocialLinks {
            self.socialLinks = SocialLinks(instagram: data.instagram.emptyToNil(),
                                           youtube: data.youtube.emptyToNil(),
                                           tiktok: data.tiktok.emptyToNil())
        } else {
            self.socialLinks = nil
        }
    }
}

private struct AgencySignupBody: Encodable {
    let nomAgence: String
    let responsable: String
    let email: String
    let motDePasse: String
    let tel: String
    let gouvernorat: String
    let siteWeb: String?
    let description: String?
    let logoUrl: String?
    let documents: String?

    init(data: AgencySignUpData) {
        self.nomAgence = data.agencyName
        self.responsable = data.responsibleName
        self.email = data.email
        self.motDePasse = data.password
        self.tel = data.phone
        self.gouvernorat = data.government
        self.siteWeb = data.website.emptyToNil()
        self.description = data.description.emptyToNil()
        self.logoUrl = data.logoBase64
        self.documents = data.adminDocumentURL?.absoluteString
    }
}

struct SocialLinks: Encodable {
    let instagram: String?
    let youtube: String?
    let tiktok: String?
}

struct UserInfo: Decodable {
    let id: String?
    let email: String?
    let role: String?
    let type: String?
    let acteurId: String?
    let agenceId: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
        case type
        case acteurId = "acteurId"
        case agenceId = "agenceId"
        case _id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let explicitId = try container.decodeIfPresent(String.self, forKey: .id)
        let mongoId = try container.decodeIfPresent(String.self, forKey: ._id)
        id = explicitId ?? mongoId
        email = try container.decodeIfPresent(String.self, forKey: .email)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        acteurId = try container.decodeIfPresent(String.self, forKey: .acteurId)
        agenceId = try container.decodeIfPresent(String.self, forKey: .agenceId)
    }
}

struct ActorProfile: Decodable {
    let id: String?
    let nom: String?
    let prenom: String?
    let email: String?
    let tel: String?
    let age: Int?
    let gouvernorat: String?
    let experience: Int?
    let cvPdf: String?
    let centresInteret: [String]?
    let photoProfil: String?
    let socialLinks: SocialLinksResponse?

    private enum CodingKeys: String, CodingKey {
        case id
        case _id
        case nom
        case prenom
        case email
        case tel
        case age
        case gouvernorat
        case experience
        case cvPdf
        case centresInteret
        case photoProfil
        case socialLinks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let explicitId = try container.decodeIfPresent(String.self, forKey: .id)
        let mongoId = try container.decodeIfPresent(String.self, forKey: ._id)
        id = explicitId ?? mongoId
        nom = try container.decodeIfPresent(String.self, forKey: .nom)
        prenom = try container.decodeIfPresent(String.self, forKey: .prenom)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        tel = try container.decodeIfPresent(String.self, forKey: .tel)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        gouvernorat = try container.decodeIfPresent(String.self, forKey: .gouvernorat)
        experience = try container.decodeIfPresent(Int.self, forKey: .experience)
        cvPdf = try container.decodeIfPresent(String.self, forKey: .cvPdf)
        centresInteret = try container.decodeIfPresent([String].self, forKey: .centresInteret)
        photoProfil = try container.decodeIfPresent(String.self, forKey: .photoProfil)
        socialLinks = try container.decodeIfPresent(SocialLinksResponse.self, forKey: .socialLinks)
    }
}

struct SocialLinksResponse: Decodable {
    let instagram: String?
    let youtube: String?
    let tiktok: String?
}

struct ActorProfileUpdate: Encodable {
    var nom: String?
    var prenom: String?
    var email: String?
    var tel: String?
    var age: Int?
    var gouvernorat: String?
    var experience: Int?
    var cvPdf: String?
    var centresInteret: [String]?
    var photoProfil: String?
    var socialLinks: SocialLinks?
}

struct CastingSummary: Decodable {
    let id: String?
    let titre: String?
    let descriptionRole: String?
    let synopsis: String?
    let lieu: String?
    let dateDebut: String?
    let dateFin: String?
    let remuneration: String?
    let role: String?
    let ageMinimum: Int?
    let ageMaximum: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case _id
        case titre
        case descriptionRole
        case synopsis
        case lieu
        case dateDebut
        case dateFin
        case remuneration
        case role
        case ageMinimum
        case ageMaximum
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let explicitId = try container.decodeIfPresent(String.self, forKey: .id)
        let mongoId = try container.decodeIfPresent(String.self, forKey: ._id)
        id = explicitId ?? mongoId
        titre = try container.decodeIfPresent(String.self, forKey: .titre)
        descriptionRole = try container.decodeIfPresent(String.self, forKey: .descriptionRole)
        synopsis = try container.decodeIfPresent(String.self, forKey: .synopsis)
        lieu = try container.decodeIfPresent(String.self, forKey: .lieu)
        dateDebut = try container.decodeIfPresent(String.self, forKey: .dateDebut)
        dateFin = try container.decodeIfPresent(String.self, forKey: .dateFin)
        remuneration = try container.decodeIfPresent(String.self, forKey: .remuneration)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        ageMinimum = try container.decodeIfPresent(Int.self, forKey: .ageMinimum)
        ageMaximum = try container.decodeIfPresent(Int.self, forKey: .ageMaximum)
    }
}

struct CastingDetail: Decodable {
    let id: String?
    let titre: String?
    let descriptionRole: String?
    let synopsis: String?
    let lieu: String?
    let dateDebut: String?
    let dateFin: String?
    let remuneration: String?
    let conditions: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case _id
        case titre
        case descriptionRole
        case synopsis
        case lieu
        case dateDebut
        case dateFin
        case remuneration
        case conditions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let explicitId = try container.decodeIfPresent(String.self, forKey: .id)
        let mongoId = try container.decodeIfPresent(String.self, forKey: ._id)
        id = explicitId ?? mongoId
        titre = try container.decodeIfPresent(String.self, forKey: .titre)
        descriptionRole = try container.decodeIfPresent(String.self, forKey: .descriptionRole)
        synopsis = try container.decodeIfPresent(String.self, forKey: .synopsis)
        lieu = try container.decodeIfPresent(String.self, forKey: .lieu)
        dateDebut = try container.decodeIfPresent(String.self, forKey: .dateDebut)
        dateFin = try container.decodeIfPresent(String.self, forKey: .dateFin)
        remuneration = try container.decodeIfPresent(String.self, forKey: .remuneration)
        conditions = try container.decodeIfPresent(String.self, forKey: .conditions)
    }
}

extension String {
    func emptyToNil() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

