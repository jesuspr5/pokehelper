import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/type_model.dart'; // Asegúrate de que tu archivo se llame así

void main() {
  runApp(const PokeTypeApp());
}

class PokeTypeApp extends StatelessWidget {
  const PokeTypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _mostrarBotonera = false;
  PokemonType? firstType;
  PokemonType? secondType;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allPokemon = []; // Aquí cargaremos el JSON
  List<dynamic> filteredPokemon = [];

  final Map<String, String> traduccion = {
    "Fire": "Fuego",
    "Water": "Agua",
    "Grass": "Planta",
    "Electric": "Eléctrico",
    "Ice": "Hielo",
    "Fighting": "Lucha",
    "Poison": "Veneno",
    "Ground": "Tierra",
    "Flying": "Volador",
    "Psychic": "Psíquico",
    "Bug": "Bicho",
    "Rock": "Roca",
    "Ghost": "Fantasma",
    "Dragon": "Dragón",
    "Dark": "Siniestro",
    "Steel": "Acero",
    "Fairy": "Hada",
    "Normal": "Normal",
  };

  // Lo que se muestra al buscar
  Future<void> loadPokemonData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/pokemon_db.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        allPokemon = data;
      });
      if (kDebugMode) {
        print(
          "✅ JSON cargado con éxito: ${allPokemon.length} pokémon encontrados",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ ERROR cargando el JSON: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadPokemonData(); // Cargamos los datos al abrir la app
  }

  @override
  void dispose() {
    // Cerramos el controlador al destruir el widget para liberar memoria
    _searchController.dispose();
    super.dispose();
  }

  void seleccionarTiposPorNombre(List<String> nombresEnIngles) {
    // Mapa de traducción (Movido fuera o mantenido aquí por simplicidad)

    setState(() {
      // RESET inicial para evitar que se queden tipos de la búsqueda anterior
      firstType = null;
      secondType = null;

      for (int i = 0; i < nombresEnIngles.length; i++) {
        String nombreTraducido =
            traduccion[nombresEnIngles[i]] ?? nombresEnIngles[i];

        try {
          final tipoEncontrado = myTypes.firstWhere(
            (t) => t.name.toLowerCase() == nombreTraducido.toLowerCase(),
          );

          if (i == 0) firstType = tipoEncontrado;
          if (i == 1) secondType = tipoEncontrado;
        } catch (e) {
          if (kDebugMode) print("Tipo no reconocido: $nombreTraducido");
        }
      }
    });
  }

  void limpiarSeleccion() {
    setState(() {
      firstType = null;
      secondType = null;
      _searchController.clear(); // Borra el texto del buscador
      filteredPokemon = []; // Limpia las sugerencias
    });
  }

  Map<String, double> calcularEfectividadDefensiva(
    PokemonType? t1,
    PokemonType? t2,
  ) {
    // 1. Creamos el mapa vacío
    Map<String, double> resultados = {};

    // 2. TRUCO: Llenamos el mapa automáticamente usando nuestra lista myTypes
    for (var tipo in myTypes) {
      resultados[tipo.name] = 1.0;
    }

    if (t1 == null && t2 == null) return resultados;

    void aplicar(PokemonType t) {
      // Debilidades (Recibe x2)
      for (var debil in t.weaknesses) {
        if (resultados.containsKey(debil)) {
          resultados[debil] = resultados[debil]! * 2.0;
        }
      }
      // Resistencias (Recibe x0.5)
      for (var fuerte in t.strengths) {
        if (resultados.containsKey(fuerte)) {
          resultados[fuerte] = resultados[fuerte]! * 0.5;
        }
      }

      // Inmunidades (Recibe x0) 👈 Agregamos esto para ser pro
      for (var inmune in t.immunities) {
        if (resultados.containsKey(inmune)) {
          resultados[inmune] = resultados[inmune]! * 0.0;
        }
      }
    }

    if (t1 != null) aplicar(t1);
    if (t2 != null) aplicar(t2);

    return resultados;
  }

  void _toggleType(PokemonType type) {
    setState(() {
      if (firstType == type) {
        firstType = secondType;
        secondType = null;
      } else if (secondType == type) {
        secondType = null;
      } else if (firstType == null) {
        firstType = type;
      } else if (secondType == null) {
        secondType = type;
        // --- MAGIA AQUÍ ---
        // Si acabamos de seleccionar el segundo tipo, cerramos el panel
        _mostrarBotonera = false;
      } else {
        secondType = type;
        // También cerramos si reemplazamos el segundo tipo
        _mostrarBotonera = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cálculos Ofensivos (Fortalezas)
    List<String> misFortalezas = [];
    if (firstType != null) misFortalezas.addAll(firstType!.strengths);
    if (secondType != null) misFortalezas.addAll(secondType!.strengths);
    // Quitamos duplicados por si ambos tipos son fuertes contra lo mismo
    misFortalezas = misFortalezas.toSet().toList();

    // 2. Cálculos Defensivos (Debilidades)
    final misDebilidades = calcularEfectividadDefensiva(firstType, secondType);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Tu imagen PNG
            TweenAnimationBuilder(
              // Cada vez que cambie el tipo, disparamos una rotación
              tween: Tween<double>(
                begin: 0,
                end: (firstType != null) ? 6.28 : 0,
              ),
              duration: const Duration(milliseconds: 500),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Image.asset('assets/pokeball.png', height: 30),
                );
              },
            ),
            const SizedBox(
              width: 10,
            ), // Un pequeño espacio entre imagen y texto
            const Text('PokeType Helper V-1.0'),
          ],
        ),
        actions: [
          if (firstType != null) // Solo se muestra si hay algo seleccionado
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Limpiar',
              onPressed: limpiarSeleccion,
            ),
        ],
      ),

      body: Column(
        children: [
          // --- 1. EL BUSCADOR (Justo al inicio del body) ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon (ej. Charizard)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    (firstType != null || _searchController.text.isNotEmpty)
                        ? IconButton(
                          icon: const Icon(Icons.backspace_outlined),
                          onPressed: limpiarSeleccion,
                        )
                        : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredPokemon = [];
                  } else {
                    filteredPokemon =
                        allPokemon
                            .where(
                              (p) => (p['name']['english'] as String)
                                  .toLowerCase()
                                  .contains(value.toLowerCase()),
                            )
                            .take(5) // Para no colapsar la pantalla
                            .toList();
                  }
                });
              },
            ),
          ),

          // --- 2. LISTA DE SUGERENCIAS (Flotante o Condicional) ---
          if (filteredPokemon.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredPokemon.length,
                itemBuilder: (context, index) {
                  final poke = filteredPokemon[index];
                  return ListTile(
                    title: Text(poke['name']['english']),
                    subtitle: Row(
                      children:
                          (poke['type'] as List).map((t) {
                            // Aquí podrías poner círculos de colores pequeños,
                            // pero por ahora solo texto con separador:
                            return Text("${traduccion[t] ?? t}  ");
                          }).toList(),
                    ),
                    onTap: () {
                      seleccionarTiposPorNombre(
                        List<String>.from(poke['type']),
                      );
                      setState(() {
                        _searchController.clear();
                        filteredPokemon = [];
                      });
                    },
                  );
                },
              ),
            ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSelectedTypeCard(firstType),
                      const SizedBox(width: 15),
                      _buildSelectedTypeCard(secondType),
                    ],
                  ),
                  if (firstType != null || secondType != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton.icon(
                        onPressed: limpiarSeleccion,
                        icon: const Icon(
                          Icons.delete_sweep_outlined,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          "Limpiar Tipos",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                  // 1. --- SECCIÓN OFENSIVA (Haces x2) ---
                  _buildInfoSection(
                    titulo: 'ATK: Eficaz contra tipos',
                    icono: Icons.bolt,
                    colorIcono: Colors.yellowAccent,
                    contenido: Wrap(
                      key: ValueKey(misFortalezas.join(',')),
                      spacing: 8,
                      children:
                          misFortalezas
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    54,
                                    245,
                                    70,
                                  ).withValues(alpha: 0.3),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // 2. --- SECCIÓN DEFENSIVA (Recibes x2 o x4) ---
                  _buildInfoSection(
                    titulo: 'DEF: Debil contra tipos',
                    icono: Icons.shield,
                    colorIcono: Colors.redAccent,
                    contenido: Wrap(
                      key: ValueKey(
                        'def-${misDebilidades.entries.where((e) => e.value > 1.0).map((e) => e.key).join()}',
                      ),
                      spacing: 8,
                      children:
                          misDebilidades.entries
                              .where((e) => e.value > 1.0) // Solo debilidades
                              .map(
                                (e) => Chip(
                                  label: Text('${e.key} x${e.value}'),
                                  backgroundColor: Colors.red.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // 3. --- SECCIÓN INMUNIDADES (Recibes x0) ---
                  _buildInfoSection(
                    titulo: 'INM: inmune al tipo ',
                    icono: Icons.shield_outlined,
                    colorIcono: Colors.white70,
                    contenido: Wrap(
                      key: ValueKey(
                        'inm-${misDebilidades.entries.where((e) => e.value == 0.0).map((e) => e.key).join()}',
                      ),
                      spacing: 8,
                      children:
                          misDebilidades.entries
                              .where((e) => e.value == 0.0) // Solo inmunidades
                              .map(
                                (e) => Chip(
                                  label: Text(e.key),
                                  backgroundColor: Colors.grey.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- VISTA PREVIA ---
          const Divider(height: 1),

          // --- BOTONERA ---
          Column(
            children: [
              ListTile(
                title: const Text(
                  "Selección de tipos",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                trailing: Icon(
                  _mostrarBotonera
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
                onTap: () {
                  setState(() {
                    _mostrarBotonera = !_mostrarBotonera;
                  });
                },
              ),
              if (_mostrarBotonera)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 250, // Ajusta la altura según tu pantalla
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: myTypes.length,
                    itemBuilder: (context, index) {
                      final type = myTypes[index];
                      final isSelected =
                          (firstType == type || secondType == type);
                      final textColor =
                          (type.name == 'Eléctrico' || type.name == 'Hielo')
                              ? Colors.black
                              : Colors.white;

                      return AnimatedScale(
                        scale:
                            isSelected
                                ? 1.05
                                : 1.0, // Se hace un 5% más grande si está seleccionado
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: type.color,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            side:
                                isSelected
                                    ? const BorderSide(
                                      color: Colors.white,
                                      width: 3,
                                    ) // Borde grueso si está seleccionado
                                    : (type.name == 'Siniestro')
                                    ? BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ) // Borde sutil para Siniestro
                                    : BorderSide.none,
                          ),
                          onPressed: () {
                            _toggleType(type);
                          },
                          child: FittedBox(
                            // 👈 Esto hace que el texto se encoja si no cabe
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                type.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String titulo,
    required IconData icono,
    required Color colorIcono,
    required Widget contenido,
  }) {
    return AnimatedSize(
      // 👈 Hace que la tarjeta crezca suavemente
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: colorIcono, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Usamos AnimatedSwitcher para que los Chips aparezcan con estilo
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: contenido,
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR: Las tarjetas de arriba (Seleccionados)
  Widget _buildSelectedTypeCard(PokemonType? type) {
    return GestureDetector(
      onTap: () {
        if (type != null) {
          // Al tocar la tarjeta, usamos la lógica de toggle para quitarlo
          _toggleType(type);
        }
      },
      child: Container(
        width: 110,
        height: 45,
        decoration: BoxDecoration(
          color: type?.color ?? Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          // Si hay tipo, le ponemos un borde para indicar que es "clicable"
          border: type != null ? Border.all(color: Colors.white24) : null,
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              type?.name ?? '---',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (type != null)
              const Positioned(
                right: 4,
                top: 4,
                child: Icon(Icons.close, size: 12, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
