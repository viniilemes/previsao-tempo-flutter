import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/cptec_service.dart';
import 'previsao_page.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key});
  @override
  State<PesquisaPage> createState() => _PesquisaPageState();
}

class _PesquisaPageState extends State<PesquisaPage> {
  final _controller = TextEditingController();
  final _service = CptecService();
  List<Cidade> _cidades = [];
  String? _erro;
  bool _carregando = false;
  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    if (_carregando) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _erro = null;
      _cidades = [];
      _carregando = true;
    });
    try {
      final cidades = await _service.buscarCidades(_controller.text);
      if (!mounted) return;
      setState(() {
        _cidades = cidades;
        if (cidades.isEmpty) _erro = 'Nenhuma cidade encontrada.';
      });
    } on CptecException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted)
        setState(() => _erro = 'Não foi possível realizar a pesquisa.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Previsão do tempo')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Consulte uma cidade brasileira',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Dados atualizados pelo CPTEC/INPE.'),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscar(),
                decoration: const InputDecoration(
                  labelText: 'Nome da cidade',
                  hintText: 'Ex.: São Paulo',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _carregando ? null : _buscar,
                icon: _carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_carregando ? 'Pesquisando...' : 'Pesquisar'),
              ),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        _cidades.isEmpty
                            ? Icons.info_outline
                            : Icons.error_outline,
                      ),
                      title: Text(_erro!),
                    ),
                  ),
                ),
              if (_cidades.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Resultados',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ..._cidades.map(
                  (cidade) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(cidade.nome),
                      subtitle: Text('UF: ${cidade.uf}  •  ID: ${cidade.id}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PrevisaoPage(cidade: cidade),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Fonte: CPTEC/INPE',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}
