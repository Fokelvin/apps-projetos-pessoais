import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class AvaliacaoModel {
  
  final String userId;
  final String barId;
  final double ratingBanheiro;
  final double ratingBebidas;
  final double ratingComidas;
  final double ratingAtendimento;
  final double ratingPrecos;
  final DateTime dataAvaliacao;

  AvaliacaoModel({
    required this.userId,
    required this.barId,
    required this.ratingBanheiro,
    required this.ratingBebidas,
    required this.ratingComidas,
    required this.ratingAtendimento,
    required this.ratingPrecos,
    required this.dataAvaliacao,
  });

  static Future<AvaliacaoModel?> buscarAvaliacaoExistente(String userId, String barId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('avaliacoes')
          .doc(barId)
          .get();
      
      if (!doc.exists) return null;

      final data = doc.data()!;
      return AvaliacaoModel(
        userId: data['userId'],
        barId: data['barId'],
        ratingBanheiro: data['ratingBanheiro'].toDouble(),
        ratingBebidas: data['ratingBebidas'].toDouble(),
        ratingComidas: data['ratingComidas'].toDouble(),
        ratingAtendimento: data['ratingAtendimento'].toDouble(),
        ratingPrecos: data['ratingPrecos'].toDouble(),
        dataAvaliacao: (data['dataAvaliacao'] as Timestamp).toDate(),
      );
    } catch (e) {
      //_logger.i.i('Erro ao buscar avaliação existente: $e');
      return null;
    }
  }

  static Future<void> salvarAvaliacao({
    required String userId,
    required String barId,
    required double ratingBanheiro,
    required double ratingBebidas,
    required double ratingComidas,
    required double ratingAtendimento,
    required double ratingPrecos,
  }) async {
    try {
      final avaliacao = AvaliacaoModel(
        userId: userId,
        barId: barId,
        ratingBanheiro: ratingBanheiro,
        ratingBebidas: ratingBebidas,
        ratingComidas: ratingComidas,
        ratingAtendimento: ratingAtendimento,
        ratingPrecos: ratingPrecos,
        dataAvaliacao: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('avaliacoes')
          .doc(barId)
          .set(avaliacao.toMap());

      await FirebaseFirestore.instance
        .collection('bares')
        .doc(barId)
        .collection('avaliacoes')
        .doc(userId)
        .set(avaliacao.toMap());

    } catch (e) {
      //_logger.i.i('Erro ao salvar avaliação: $e');
      rethrow;
    }
  }

  static Future<void> atualizarAvaliacao({
    required String userId,
    required String barId,
    required double ratingBanheiro,
    required double ratingBebidas,
    required double ratingComidas,
    required double ratingAtendimento,
    required double ratingPrecos,
  }) async {
    try {
      final avaliacao = AvaliacaoModel(
        userId: userId,
        barId: barId,
        ratingBanheiro: ratingBanheiro,
        ratingBebidas: ratingBebidas,
        ratingComidas: ratingComidas,
        ratingAtendimento: ratingAtendimento,
        ratingPrecos: ratingPrecos,
        dataAvaliacao: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('avaliacoes')
          .doc(barId)
          .update(avaliacao.toMap());

              // Atualiza na coleção do bar
    await FirebaseFirestore.instance
        .collection('bares')
        .doc(barId)
        .collection('avaliacoes')
        .doc(userId)
        .update(avaliacao.toMap());

    } catch (e) {
      //_logger.i.i('Erro ao atualizar avaliação: $e');
      rethrow;
    }
  }

  static bool validarAvaliacao({
    required double ratingBanheiro,
    required double ratingBebidas,
    required double ratingComidas,
    required double ratingAtendimento,
    required double ratingPrecos,
  }) {
    return ratingBanheiro > 0 && 
           ratingBebidas > 0 && 
           ratingComidas > 0 && 
           ratingAtendimento > 0 && 
           ratingPrecos > 0;
  }

  static Future<Map<String, dynamic>> processarAvaliacao({
    required String userId,
    required String barId,
    required double ratingBanheiro,
    required double ratingBebidas,
    required double ratingComidas,
    required double ratingAtendimento,
    required double ratingPrecos,
  }) async {
    try {
      if (!validarAvaliacao(
        ratingBanheiro: ratingBanheiro,
        ratingBebidas: ratingBebidas,
        ratingComidas: ratingComidas,
        ratingAtendimento: ratingAtendimento,
        ratingPrecos: ratingPrecos,
      )) {
        return {
          'success': false,
          'message': 'Por favor, avalie todos os itens',
        };
      }

      final avaliacaoExistente = await buscarAvaliacaoExistente(userId, barId);
      
      if (avaliacaoExistente != null) {
        await atualizarAvaliacao(
          userId: userId,
          barId: barId,
          ratingBanheiro: ratingBanheiro,
          ratingBebidas: ratingBebidas,
          ratingComidas: ratingComidas,
          ratingAtendimento: ratingAtendimento,
          ratingPrecos: ratingPrecos,
        );
        return {
          'success': true,
          'message': 'Avaliação atualizada com sucesso!',
          'jaAvaliou': true,
        };
      } else {
        await salvarAvaliacao(
          userId: userId,
          barId: barId,
          ratingBanheiro: ratingBanheiro,
          ratingBebidas: ratingBebidas,
          ratingComidas: ratingComidas,
          ratingAtendimento: ratingAtendimento,
          ratingPrecos: ratingPrecos,
        );
        return {
          'success': true,
          'message': 'Avaliação salva com sucesso!',
          'jaAvaliou': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao processar avaliação: $e',
      };
    }
  }

static Future<Map<String, dynamic>> carregarAvaliacaoExistente(String userId, String barId) async {
  try {
    final avaliacao = await buscarAvaliacaoExistente(userId, barId);
    
    if (avaliacao == null) {
      return {
        'success': true,
        'jaAvaliou': false,
        'ratings': {
          'banheiro': 0.0,
          'bebidas': 0.0,
          'comidas': 0.0,
          'atendimento': 0.0,
          'precos': 0.0,
        }
      };
    }

    return {
      'success': true,
      'jaAvaliou': true,
      'ratings': {
        'banheiro': avaliacao.ratingBanheiro,
        'bebidas': avaliacao.ratingBebidas,
        'comidas': avaliacao.ratingComidas,
        'atendimento': avaliacao.ratingAtendimento,
        'precos': avaliacao.ratingPrecos,
      }
    };
  } catch (e) {
    //_logger.i.i('Erro ao carregar avaliação existente: $e');
    return {
      'success': false,
      'message': 'Erro ao carregar avaliação existente: $e',
    };
  }
}

static Future<Map<String, dynamic>> calcularMediaAvaliacoes(String barId) async {
  try {
    //_logger.i.i('Buscando avaliações para o barId: $barId');
    
    // Busca todas as avaliações do estabelecimento
    final querySnapshot = await FirebaseFirestore.instance
        .collection('bares')
        .doc(barId)
        .collection('avaliacoes')
        .get();

    //_logger.i.i('Total de avaliações encontradas: ${querySnapshot.docs.length}');
    
    if (querySnapshot.docs.isEmpty) {
      //_logger.i.i('Nenhuma avaliação encontrada para este estabelecimento');
      return {
        'success': true,
        'mediaGeral': 0.0,
        'medias': {
          'banheiro': 0.0,
          'bebidas': 0.0,
          'comidas': 0.0,
          'atendimento': 0.0,
          'precos': 0.0,
        },
        'totalAvaliacoes': 0,
      };
    }

    double somaBanheiro = 0;
    double somaBebidas = 0;
    double somaComidas = 0;
    double somaAtendimento = 0;
    double somaPrecos = 0;
    int totalAvaliacoes = querySnapshot.docs.length;

    //_logger.i.i('\nDados das avaliações:');
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      //_logger.i.i('\nAvaliação do usuário ${data['userId']}:');
      //_logger.i.i('Banheiro: ${data['ratingBanheiro']}');
      //_logger.i.i('Bebidas: ${data['ratingBebidas']}');
      //_logger.i.i('Comidas: ${data['ratingComidas']}');
      //_logger.i.i('Atendimento: ${data['ratingAtendimento']}');
      //_logger.i.i('Preços: ${data['ratingPrecos']}');
      
      somaBanheiro += data['ratingBanheiro'] as double;
      somaBebidas += data['ratingBebidas'] as double;
      somaComidas += data['ratingComidas'] as double;
      somaAtendimento += data['ratingAtendimento'] as double;
      somaPrecos += data['ratingPrecos'] as double;
    }

    final mediaBanheiro = somaBanheiro / totalAvaliacoes;
    final mediaBebidas = somaBebidas / totalAvaliacoes;
    final mediaComidas = somaComidas / totalAvaliacoes;
    final mediaAtendimento = somaAtendimento / totalAvaliacoes;
    final mediaPrecos = somaPrecos / totalAvaliacoes;

    final mediaGeral = (mediaBanheiro + mediaBebidas + mediaComidas + 
                       mediaAtendimento + mediaPrecos) / 5;

    //_logger.i.i('\nMédias calculadas:');
    //_logger.i.i('Média Geral: $mediaGeral');
    //_logger.i.i('Média Banheiro: $mediaBanheiro');
    //_logger.i.i('Média Bebidas: $mediaBebidas');
    //_logger.i.i('Média Comidas: $mediaComidas');
    //_logger.i.i('Média Atendimento: $mediaAtendimento');
    //_logger.i.i('Média Preços: $mediaPrecos');
    //_logger.i.i('Total de Avaliações: $totalAvaliacoes');

    return {
      'success': true,
      'mediaGeral': mediaGeral,
      'medias': {
        'banheiro': mediaBanheiro,
        'bebidas': mediaBebidas,
        'comidas': mediaComidas,
        'atendimento': mediaAtendimento,
        'precos': mediaPrecos,
      },
      'totalAvaliacoes': totalAvaliacoes,
    };
  } catch (e) {
    //_logger.i.f('Erro ao calcular médias: $e');
    return {
      'success': false,
      'message': 'Erro ao calcular médias: $e',
    };
  }
}

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'barId': barId,
      'ratingBanheiro': ratingBanheiro,
      'ratingBebidas': ratingBebidas,
      'ratingComidas': ratingComidas,
      'ratingAtendimento': ratingAtendimento,
      'ratingPrecos': ratingPrecos,
      'dataAvaliacao': Timestamp.fromDate(dataAvaliacao),
    };
  }
} 