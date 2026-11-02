import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DescogeoApp());
}

class DescogeoApp extends StatelessWidget {
  const DescogeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Descogeo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class Country {
  final String name;
  final String flag;
  final String capital;
  final String continent;
  final int population;
  final String languages;
  final String currency;

  const Country({
    required this.name,
    required this.flag,
    required this.capital,
    required this.continent,
    required this.population,
    required this.languages,
    required this.currency,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // A countries.dev retorna os dados em uma estrutura mais simples.
    final languageData = json['languages'] as List<dynamic>? ?? [];
    final currencyData = json['currencies'] as List<dynamic>? ?? [];

    final languageNames = languageData
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
    final currencyNames = currencyData
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    return Country(
      name: json['name']?.toString() ?? 'Nome não informado',
      flag: json['flag']?.toString() ?? '🌍',
      capital: json['capital']?.toString() ?? 'Não informada',
      continent: json['region']?.toString() ?? 'Não informado',
      population: (json['population'] as num?)?.toInt() ?? 0,
      languages: languageNames.isEmpty ? 'Não informado' : languageNames,
      currency: currencyNames.isEmpty ? 'Não informada' : currencyNames,
    );
  }
}

class CountryService {
  // Endpoint que já devolve um único país aleatório em JSON.
  static const String _url = 'https://countries.dev/random';

  Future<Country> getRandomCountry({String? previousName}) async {
    // GET faz a requisição HTTP. O await aguarda a resposta sem travar a tela.
    final response = await http.get(Uri.parse(_url)).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode != 200) {
      throw Exception('A API retornou o erro ${response.statusCode}.');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final country = Country.fromJson(data);
    if (country.name == 'Nome não informado') {
      throw Exception('A resposta da API não contém o nome do país.');
    }
    return country;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CountryService _service = CountryService();
  Country? _country;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _discoverCountry();
  }

  Future<void> _discoverCountry() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getRandomCountry(
        previousName: _country?.name,
      );
      if (!mounted) return;
      setState(() => _country = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error =
          'Não foi possível carregar um país. Verifique sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPopulation(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F8),
        title: const Row(
          children: [
            Icon(Icons.public, color: Color(0xFF176B87)),
            SizedBox(width: 9),
            Text('Descogeo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'O mundo em uma descoberta.',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Descubra um lugar aleatório e conheça um pouco mais sobre ele.',
                    style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade700),
                  ),
                  const SizedBox(height: 24),
                  if (_loading && _country == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 70),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null && _country == null)
                    _messageCard(_error!, Icons.wifi_off)
                  else if (_country != null)
                    _countryCard(_country!),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _loading ? null : _discoverCountry,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.explore),
                    label: Text(_loading ? 'Buscando...' : 'Descobrir lugar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF176B87),
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (_error != null && _country != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Dados fornecidos pela countries.dev API',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _countryCard(Country country) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A API fornece a bandeira como emoji, então não precisamos
            // baixar uma imagem separada.
            Center(
              child: Text(country.flag, style: const TextStyle(fontSize: 76)),
            ),
            const SizedBox(height: 18),
            Text(
              country.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _infoRow(Icons.location_city, 'Capital', country.capital),
            _infoRow(Icons.public, 'Continente', country.continent),
            _infoRow(Icons.people_alt_outlined, 'População', _formatPopulation(country.population)),
            _infoRow(Icons.translate, 'Idiomas', country.languages),
            _infoRow(Icons.payments_outlined, 'Moeda', country.currency),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF176B87), size: 21),
          const SizedBox(width: 12),
          SizedBox(
            width: 94,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _messageCard(String message, IconData icon) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
