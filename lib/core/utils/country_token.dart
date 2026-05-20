class CountryToken {
  final String name;
  final String code;
  final String flag;
  final String maskHint;

  const CountryToken({
    required this.name,
    required this.code,
    required this.flag,
    required this.maskHint,
  });
}

const List<CountryToken> supportedCountries = [
  CountryToken(name: 'Sénégal', code: '+221', flag: '🇸🇳', maskHint: '77 123 45 67'),
  CountryToken(name: 'Mali', code: '+223', flag: '🇲🇱', maskHint: '66 12 34 56'),
  CountryToken(name: 'Côte d’Ivoire', code: '+225', flag: '🇨🇮', maskHint: '07 12 34 56 78'),
  CountryToken(name: 'Guinée', code: '+224', flag: '🇬🇳', maskHint: '611 12 34 56'),
  CountryToken(name: 'Mauritanie', code: '+222', flag: '🇲🇷', maskHint: '45 12 34 56'),
];