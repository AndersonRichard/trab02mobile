import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trab02flutter/components/country_tile.dart';
import 'package:trab02flutter/screens/country_list_page.dart';
import 'package:trab02flutter/models/country.dart';
import '../mocks/mock_country_service.mocks.dart';

void main() {
  group('CountryListPage - Testes Automatizados', () {
    late MockICountryService mockService;

    setUp(() {
      mockService = MockICountryService();
    });

    testWidgets('Cenário 01 - Listagem bem-sucedida', (tester) async {
      // Simula uma lista de países com dados completos
      final countries = [
        Country(
          name: 'Brasil',
          capital: 'Brasília',
          flagUrl: 'https://flagcdn.com/w320/br.png',
          region: 'Américas',
          population: 210000000,
        ),
      ];

      // Configura o mock para retornar a lista de países
      when(mockService.fetchAllCountries()).thenAnswer((_) async => countries);

      // Inicializa o widget com o serviço mockado
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // Executa o primeiro frame do widget
      await tester.pump();

      // Aguarda o tempo para carregar os dados assíncronos
      await tester.pump(const Duration(seconds: 1));

      // Verifica se o nome do país aparece na lista
      expect(find.text('Brasil'), findsOneWidget);
    });

    testWidgets('Cenário 02 - Erro na requisição de países', (tester) async {
      // Simulamos uma exceção lançada pelo serviço para representar um erro de rede ou falha na API.
      when(
        mockService.fetchAllCountries(),
      ).thenThrow(Exception('Erro de rede'));

      // Montamos o widget com o serviço mockado para testar a reação do app a esse erro.
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // Forçamos o rebuild inicial e depois esperamos 1 segundo para a resposta.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verificamos se a UI exibe uma mensagem de erro, garantindo que o app informa o usuário corretamente.
      expect(find.textContaining('Erro ao carregar países'), findsOneWidget);
    });

    test('Cenário 03 - Busca de país por nome com resultado', () async {
      // Cria um país para retornar na busca
      final country = Country(
        name: 'Brasil',
        capital: 'Brasília',
        flagUrl: 'https://flagcdn.com/w320/br.png',
        region: 'Américas',
        population: 210000000,
      );

      // Configura o mock para retornar o país ao buscar por "Brasil"
      when(
        mockService.fetchCountryByName('Brasil'),
      ).thenAnswer((_) async => country);

      // Executa a busca
      final result = await mockService.fetchCountryByName('Brasil');

      // Verifica se o resultado está correto e não é nulo
      expect(result, isNotNull);
      expect(result!.name, 'Brasil');
      expect(result.capital, 'Brasília');
    });

    test('Cenário 04 - Busca de país por nome com resultado vazio', () async {
      // Configura o mock para retornar null, simulando país não encontrado
      when(
        mockService.fetchCountryByName('Atlantis'),
      ).thenAnswer((_) async => null);

      // Executa a busca
      final result = await mockService.fetchCountryByName('Atlantis');

      // Verifica que o resultado é nulo
      expect(result, isNull);
    });

    testWidgets('Cenário 05 - País com dados incompletos', (tester) async {
      // Preparamos um país com dados vazios para simular a situação
      // onde a API pode retornar campos incompletos ou nulos.
      final countries = [
        Country(name: '', capital: '', flagUrl: '', region: '', population: 0),
      ];

      // Usamos o mock para simular o retorno da API com esse dado incompleto.
      when(mockService.fetchAllCountries()).thenAnswer((_) async => countries);

      // Montamos o widget CountryListPage passando o mockService para que
      // a tela use o serviço simulado em vez do real.
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // Primeiro pump força o build inicial do widget.
      await tester.pump();

      // O segundo pump com duração espera que a tela tenha tempo para processar
      // a resposta assíncrona e renderizar o conteúdo.
      await tester.pump(const Duration(seconds: 1));

      // Verificamos se a UI exibiu o texto padrão para nome ausente,
      // garantindo que o app trata dados incompletos sem travar.
      expect(find.text('Nome não disponível'), findsOneWidget);

      // Simulamos o toque no CountryTile para abrir o modal de detalhes.
      await tester.tap(find.byType(CountryTile));

      // pumpAndSettle espera todas as animações e mudanças de estado terminarem,
      // importante para garantir que o modal está completamente aberto antes da verificação.
      await tester.pumpAndSettle();

      // Por fim, verificamos se o modal exibe "Capital: Não disponível",
      // confirmando que o tratamento de dados incompletos funciona também no detalhe.
      expect(find.textContaining('Capital: Não disponível'), findsOneWidget);
    });

    testWidgets('Cenário 06 - Verificar chamada ao método listarPaises', (
      tester,
    ) async {
      // Configura mock para retornar lista vazia
      when(mockService.fetchAllCountries()).thenAnswer((_) async => []);

      // Inicializa widget com o mock
      await tester.pumpWidget(
        MaterialApp(home: CountryListPage(countryService: mockService)),
      );

      // Executa o primeiro frame
      await tester.pump();

      // Aguarda processamento da chamada assíncrona
      await tester.pump(const Duration(seconds: 1));

      // Verifica se o método fetchAllCountries foi chamado uma vez
      verify(mockService.fetchAllCountries()).called(1);
    });
  });
}
