// features/auth/data/models/register_user_dto.dart
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';


class RegisterUserDto {
  static Map<String, dynamic> toJson(RegistrationEntity entity) {
    return {
      "firstName": entity.firstName,
      "lastName": entity.lastName,
      "sex": entity.sex,
      "phone": entity.phone,
      "email": entity.email,
      "username": entity.username,
      "password": entity.password,
    };
  }
}


class RegisterApplicantDto {
  static Map<String, dynamic> toJson({
    required RegistrationEntity entity,
    required List<String> files, // Reçoit le document déjà converti de manière asynchrone
  }) {
    return {
      "user": {
        "firstName": entity.firstName.trim(),
        "lastName": entity.lastName.trim(),
        "sex": entity.sex,
        "phone": entity.phone.trim(),
        "email": entity.email.trim(),
        "username": entity.username.trim(),
        "password": entity.password,
        "roles": []
      },
      "identities": [
        {
          "type": entity.documentType, // Dynamique : 'CNI' ou 'PASSPORT'
          "value": entity.cni.replaceAll(' ', ''),
          // Inclusion de la chaîne Base64 résolue de manière propre
          "files": files
        }
      ],
      "placeBirth": entity.placeBirth.trim(),
      "dateBirth": entity.dateBirth,
      "residCountryId": entity.residCountryId,
      "residRegionId": entity.residRegionId,
      "residDepartmentId": entity.residDepartmentId,
      // "residMunicipalityId": entity.residMunicipalityId,
      "residAddress": entity.residAddress.trim(),
      // Maintien excellent de la coquille du backend 'nationaliteyId' détectée dans Postman !
      "nationaliteyId": entity.nationalityId 
    };
  }
}