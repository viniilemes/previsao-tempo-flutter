import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';
import '../services/cache_service.dart';
import '../services/condicoes.dart';
import '../services/cptec_service.dart';
import '../widgets/temperature_chart.dart';

class PrevisaoPage extends StatefulWidget {
  const PrevisaoPage({required this.cidade, super.key});
  final Cidade cidade;
  @override
  State<PrevisaoPage> createState() => _PrevisaoPageState();
}

class _PrevisaoPageState extends State<PrevisaoPage> {
  final _service = CptecService();
  final _cache = CacheService();
  Previsao? _previsao;
  DateTime? _salvoEm;
  bool _carregando = true;
  bool _cacheado = false;
  String? _erro;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final cached = await _cache.ler();
      if (cached != null && cached.cidade.id == widget.cidade.id && mounted)
        setState(() {
          _previsao = cached.previsao;
          _salvoEm = cached.salvoEm;
          _cacheado = true;
        });
    } catch (_) {}
    await _atualizar(silencioso: true);
  }

  Future<void> _atualizar({bool silencioso = false}) async {
    if (!_carregando && mounted)
      setState(() {
        _carregando = true;
        _erro = null;
      });
    try {
      final result = await _service.buscarPrevisao(widget.cidade);
      await _cache.salvar(widget.cidade, result);
      if (!mounted) return;
      setState(() {
        _previsao = result;
        _cacheado = false;
        _salvoEm = DateTime.now();
      });
    } on CptecException catch (e) {
      if (mounted)
        setState(() {
          _erro = e.message;
          _cacheado = _previsao != null;
        });
    } catch (_) {
      if (mounted)
        setState(() => _erro = 'Falha inesperada ao atualizar a previsão.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _data(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.isEmpty ? 'Não informado' : value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  String _temp(double? value) =>
      value == null ? 'Não informado' : '${value.toStringAsFixed(0)} °C';
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Previsão'),
          actions: [
            IconButton(
              onPressed: _carregando ? null : _atualizar,
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _atualizar,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_previsao == null && _carregando)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_erro != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    title: Text(_erro!),
                    subtitle: const Text(
                      'Os dados anteriores continuam disponíveis, se houver.',
                    ),
                    trailing: TextButton(
                      onPressed: _carregando ? null : _atualizar,
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                ),
              if (_previsao != null) ...[
                _header(),
                if (_cacheado)
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.save),
                      title: const Text('Exibindo dados salvos'),
                      subtitle: Text(
                        'Cache armazenado em ${_salvoEm == null ? 'Não informado' : _salvoEm!.toLocal()}',
                      ),
                    ),
                  ),
                TemperatureChart(dias: _previsao!.dias),
                const SizedBox(height: 12),
                ..._previsao!.dias.map(_card),
                const SizedBox(height: 16),
                const Text(
                  'Fonte: CPTEC/INPE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      );
  Widget _header() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_previsao!.nome} - ${_previsao!.uf}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('Atualização do serviço: ${_data(_previsao!.atualizacao)}'),
          const SizedBox(height: 16),
        ],
      );
  Widget _card(DiaPrevisao dia) {
    final cond = condicaoPara(dia.tempo);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              cond.icone,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _data(dia.dia),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(cond.descricao),
                  const SizedBox(height: 8),
                  Text(
                    'Mínima: ${_temp(dia.minima)}   Máxima: ${_temp(dia.maxima)}',
                  ),
                  if (dia.iuv != null)
                    Text('Índice UV: ${dia.iuv!.toStringAsFixed(1)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
