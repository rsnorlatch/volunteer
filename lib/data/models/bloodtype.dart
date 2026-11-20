enum BloodType { aPlus, aMin, bPlus, bMin, oPlus, oMin, abPlus, abMin }

extension BloodTypeLabel on BloodType {
  String get label {
    switch (this) {
      case BloodType.aPlus:
        return 'A+';
      case BloodType.aMin:
        return 'A-';
      case BloodType.bPlus:
        return 'B+';
      case BloodType.bMin:
        return 'B-';
      case BloodType.oPlus:
        return 'O+';
      case BloodType.oMin:
        return 'O-';
      case BloodType.abPlus:
        return 'AB+';
      case BloodType.abMin:
        return 'AB-';
    }
  }
}
