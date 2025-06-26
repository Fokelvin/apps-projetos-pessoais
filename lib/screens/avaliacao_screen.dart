// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/avaliacao_model.dart';

class AvaliacoesScreen extends StatefulWidget {
  final String barId;

  const AvaliacoesScreen({
    super.key,
    required this.barId,
  });

  @override
  State<AvaliacoesScreen> createState() => _AvaliacoesScreenState();
}

class _AvaliacoesScreenState extends State<AvaliacoesScreen> {
  double _ratingBanheiro = 0;
  double _ratingBebidas = 0;
  double _ratingComidas = 0;
  double _ratingAtendimento = 0;
  double _ratingPrecos = 0;
  bool _isLoading = false;
  bool _jaAvaliou = false;

  @override
  void initState() {
    super.initState();
    _verificarAvaliacaoExistente();
  }

  Future<void> _verificarAvaliacaoExistente() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final avaliacao = await AvaliacaoModel.buscarAvaliacaoExistente(
        userProvider.userId,
        widget.barId,
      );

      if (avaliacao != null) {
        setState(() {
          _ratingBanheiro = avaliacao.ratingBanheiro;
          _ratingBebidas = avaliacao.ratingBebidas;
          _ratingComidas = avaliacao.ratingComidas;
          _ratingAtendimento = avaliacao.ratingAtendimento;
          _ratingPrecos = avaliacao.ratingPrecos;
          _jaAvaliou = true;
        });
      }
    } catch (e) {
      print('Erro ao verificar avaliação existente: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _salvarAvaliacao() async {
  setState(() => _isLoading = true);

  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final resultado = await AvaliacaoModel.processarAvaliacao(
      userId: userProvider.userId,
      barId: widget.barId,
      ratingBanheiro: _ratingBanheiro,
      ratingBebidas: _ratingBebidas,
      ratingComidas: _ratingComidas,
      ratingAtendimento: _ratingAtendimento,
      ratingPrecos: _ratingPrecos,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado['message']),
        backgroundColor: resultado['success'] ? Colors.green : Colors.red,
      ),
    );

    if (resultado['success']) {
      Navigator.pop(context);
    }
  } catch (e) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao processar avaliação'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avaliar Estabelecimento"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_jaAvaliou)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Você já avaliou este estabelecimento. Você pode atualizar sua avaliação.',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildRatingItem(
                      "Banheiro",
                      Icons.wc,
                      _ratingBanheiro,
                      (value) => setState(() => _ratingBanheiro = value),
                    ),
                    const Divider(),
                    _buildRatingItem(
                      "Bebidas",
                      Icons.local_bar,
                      _ratingBebidas,
                      (value) => setState(() => _ratingBebidas = value),
                    ),
                    const Divider(),
                    _buildRatingItem(
                      "Comidas",
                      Icons.restaurant,
                      _ratingComidas,
                      (value) => setState(() => _ratingComidas = value),
                    ),
                    const Divider(),
                    _buildRatingItem(
                      "Atendimento",
                      Icons.group,
                      _ratingAtendimento,
                      (value) => setState(() => _ratingAtendimento = value),
                    ),
                    const Divider(),
                    _buildRatingItem(
                      "Preços",
                      Icons.currency_exchange,
                      _ratingPrecos,
                      (value) => setState(() => _ratingPrecos = value),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _salvarAvaliacao,
                        child: Text(
                          _jaAvaliou ? "Atualizar Avaliação" : "Salvar Avaliação",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRatingItem(
    String title,
    IconData icon,
    double rating,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onChanged(index + 1.0),
              );
            }),
          ),
        ],
      ),
    );
  }
}