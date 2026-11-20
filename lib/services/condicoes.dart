import 'package:flutter/material.dart';

class Condicao {
  const Condicao(this.descricao, this.icone);
  final String descricao;
  final IconData icone;
}

const Map<String, Condicao> condicoes = {
  'ec': Condicao('Encoberto com chuvas isoladas', Icons.cloudy_snowing),
  'ci': Condicao('Chuvas isoladas', Icons.grain),
  'c': Condicao('Chuva', Icons.umbrella),
  'in': Condicao('Instável', Icons.cloud),
  'pp': Condicao('Possibilidade de pancadas de chuva', Icons.cloudy_snowing),
  'cm': Condicao('Chuva pela manhã', Icons.cloud_queue),
  'cn': Condicao('Chuva à noite', Icons.nights_stay),
  'pt': Condicao('Pancadas de chuva à tarde', Icons.thunderstorm),
  'pm': Condicao('Pancadas de chuva pela manhã', Icons.thunderstorm),
  'np': Condicao('Nublado e pancadas de chuva', Icons.thunderstorm),
  'pc': Condicao('Pancadas de chuva', Icons.thunderstorm),
  'pn': Condicao('Parcialmente nublado', Icons.cloud),
  'cv': Condicao('Chuvisco', Icons.grain),
  'ch': Condicao('Chuvoso', Icons.umbrella),
  't': Condicao('Tempestade', Icons.flash_on),
  'ps': Condicao('Predomínio de sol', Icons.wb_sunny),
  'e': Condicao('Encoberto', Icons.cloud),
  'n': Condicao('Nublado', Icons.cloud),
  'cl': Condicao('Céu claro', Icons.wb_sunny),
  'nv': Condicao('Nevoeiro', Icons.foggy),
  'g': Condicao('Geada', Icons.ac_unit),
  'ne': Condicao('Neve', Icons.ac_unit),
  'nd': Condicao('Não definido', Icons.help_outline),
  'pnt': Condicao('Pancadas de chuva à noite', Icons.thunderstorm),
  'psc': Condicao('Possibilidade de chuva', Icons.cloud_queue),
  'pcm': Condicao('Possibilidade de chuva pela manhã', Icons.cloud_queue),
  'pct': Condicao('Possibilidade de chuva à tarde', Icons.cloud_queue),
  'pcn': Condicao('Possibilidade de chuva à noite', Icons.cloud_queue),
  'npt': Condicao('Nublado com pancadas à tarde', Icons.thunderstorm),
  'npn': Condicao('Nublado com pancadas à noite', Icons.thunderstorm),
  'ncn': Condicao(
    'Nublado com possibilidade de chuva à noite',
    Icons.cloud_queue,
  ),
  'nct': Condicao(
    'Nublado com possibilidade de chuva à tarde',
    Icons.cloud_queue,
  ),
  'ncm': Condicao(
    'Nublado com possibilidade de chuva pela manhã',
    Icons.cloud_queue,
  ),
  'npm': Condicao('Nublado com pancadas pela manhã', Icons.thunderstorm),
  'npp': Condicao('Nublado com possibilidade de chuva', Icons.cloud_queue),
  'vn': Condicao('Variação de nebulosidade', Icons.cloud),
  'ct': Condicao('Chuva à tarde', Icons.umbrella),
  'ppn': Condicao('Possibilidade de pancadas à noite', Icons.cloud_queue),
  'ppt': Condicao('Possibilidade de pancadas à tarde', Icons.cloud_queue),
  'ppm': Condicao('Possibilidade de pancadas pela manhã', Icons.cloud_queue),
};

Condicao condicaoPara(String sigla) =>
    condicoes[sigla.toLowerCase()] ??
    const Condicao('Condição não informada', Icons.help_outline);
