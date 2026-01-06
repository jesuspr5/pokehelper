import 'package:flutter/material.dart';

class PokemonType {
  final String name;
  final List<String> strengths; // Contra quién es fuerte (hace x2)
  final List<String> weaknesses; // Contra quién es débil (recibe x2)
  final List<String> immunities; // A quién no le hace daño (x0)
  final Color color;

  // Este es el constructor: sirve para crear un tipo nuevo
  PokemonType({
    required this.name,
    required this.strengths,
    required this.weaknesses,
    required this.color,
    this.immunities = const [], // Es opcional, por defecto vacía
  });
}

// Esta es tu "Base de datos" inicial
List<PokemonType> myTypes = [
  PokemonType(
    name: 'Normal',
    color: Colors.grey,
    strengths: [],
    weaknesses: ['Lucha'],
    immunities: ['Fantasma'],
  ),
  PokemonType(
    name: 'Fuego',
    color: Colors.orange,
    strengths: ['Planta', 'Hielo', 'Bicho', 'Acero'],
    weaknesses: ['Agua', 'Tierra', 'Roca'],
  ),
  PokemonType(
    name: 'Agua',
    color: Colors.blue,
    strengths: ['Fuego', 'Tierra', 'Roca'],
    weaknesses: ['Planta', 'Eléctrico'],
  ),
  PokemonType(
    name: 'Planta',
    color: Colors.green,
    strengths: ['Agua', 'Tierra', 'Roca'],
    weaknesses: ['Fuego', 'Hielo', 'Veneno', 'Volador', 'Bicho'],
  ),
  PokemonType(
    name: 'Eléctrico',
    color: Colors.yellow,
    strengths: ['Agua', 'Volador'],
    weaknesses: ['Tierra'],
  ),
  PokemonType(
    name: 'Hielo',
    color: Colors.cyan,
    strengths: ['Planta', 'Tierra', 'Volador', 'Dragón'],
    weaknesses: ['Fuego', 'Lucha', 'Roca', 'Acero'],
  ),
  PokemonType(
    name: 'Lucha',
    color: Colors.redAccent,
    strengths: ['Normal', 'Hielo', 'Roca', 'Siniestro', 'Acero'],
    weaknesses: ['Volador', 'Psíquico', 'Hada'],
  ),
  PokemonType(
    name: 'Veneno',
    color: Colors.purple,
    strengths: ['Planta', 'Hada'],
    weaknesses: ['Tierra', 'Psíquico'],
  ),
  PokemonType(
    name: 'Tierra',
    color: Colors.brown,
    strengths: ['Fuego', 'Eléctrico', 'Veneno', 'Roca', 'Acero'],
    weaknesses: ['Agua', 'Planta', 'Hielo'],
    immunities: ['Eléctrico'],
  ),
  PokemonType(
    name: 'Volador',
    color: Colors.indigoAccent,
    strengths: ['Planta', 'Lucha', 'Bicho'],
    weaknesses: ['Eléctrico', 'Hielo', 'Roca'],
    immunities: ['Tierra'],
  ),
  PokemonType(
    name: 'Psíquico',
    color: Colors.pinkAccent,
    strengths: ['Lucha', 'Veneno'],
    weaknesses: ['Bicho', 'Fantasma', 'Siniestro'],
  ),
  PokemonType(
    name: 'Bicho',
    color: Colors.lightGreen,
    strengths: ['Planta', 'Psíquico', 'Siniestro'],
    weaknesses: ['Fuego', 'Volador', 'Roca'],
  ),
  PokemonType(
    name: 'Roca',
    color: const Color(0xFFB6A136),
    strengths: ['Fuego', 'Hielo', 'Volador', 'Bicho'],
    weaknesses: ['Agua', 'Planta', 'Lucha', 'Tierra', 'Acero'],
  ),
  PokemonType(
    name: 'Fantasma',
    color: Colors.deepPurple,
    strengths: ['Psíquico', 'Fantasma'],
    weaknesses: ['Fantasma', 'Siniestro'],
    immunities: ['Normal', 'Lucha'],
  ),
  PokemonType(
    name: 'Dragón',
    color: Colors.indigo,
    strengths: ['Dragón'],
    weaknesses: ['Hielo', 'Dragón', 'Hada'],
  ),
  PokemonType(
    name: 'Siniestro',
    color: Colors.black54,
    strengths: ['Psíquico', 'Fantasma'],
    weaknesses: ['Lucha', 'Bicho', 'Hada'],
    immunities: ['Psíquico'],
  ),
  PokemonType(
    name: 'Acero',
    color: const Color(0xFFB7B7CE),
    strengths: ['Hielo', 'Roca', 'Hada'],
    weaknesses: ['Fuego', 'Lucha', 'Tierra'],
  ),
  PokemonType(
    name: 'Hada',
    color: Colors.pink,
    strengths: ['Lucha', 'Dragón', 'Siniestro'],
    weaknesses: ['Veneno', 'Acero'],
    immunities: ['Dragón'],
  ),
];
