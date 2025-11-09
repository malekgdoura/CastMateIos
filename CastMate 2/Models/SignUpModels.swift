import SwiftUI

enum SignUpFlow: Equatable {
    case roleSelection
    case actorStep1, actorStep2, actorStep3
    case agencyStep1, agencyStep2
}

// Data collected along the steps
struct ActorSignUpData {
    // Step 1
    var firstName = ""
    var lastName = ""
    var age = ""
    var email = ""
    var password = ""
    var phone = ""
    var government = ""
    var profileImage: UIImage? = nil

    // Step 2
    var yearsOfExperience = ""
    var cvURL: URL? = nil
    var instagram = ""
    var tiktok = ""
    var youtube = ""

    // Step 3
    var interests: Set<String> = []
    var tags: [String] = []
}

struct AgencySignUpData {
    // Step 1
    var agencyName = ""
    var responsibleName = ""
    var email = ""
    var password = ""
    var phone = ""
    var government = ""

    // Step 2
    var website = ""
    var description = ""
    var logo: UIImage? = nil
    var adminDocumentURL: URL? = nil
}

extension ActorSignUpData {
    var profileImageBase64: String? {
        guard let profileImage,
              let data = profileImage.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        return data.base64EncodedString()
    }

    var hasSocialLinks: Bool {
        !instagram.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || !tiktok.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || !youtube.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension AgencySignUpData {
    var logoBase64: String? {
        guard let logo,
              let data = logo.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        return data.base64EncodedString()
    }
}
