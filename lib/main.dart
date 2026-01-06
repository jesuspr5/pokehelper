import 'package:flutter/material.dart';
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
  PokemonType? firstType;
  PokemonType? secondType;

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
            Image.asset(
              'assets/pokeball.png',
              height: 30, // Ajusta el tamaño para que no se vea gigante
            ),
            const SizedBox(
              width: 10,
            ), // Un pequeño espacio entre imagen y texto
            const Text('PokeType Helper V-1.0'),
          ],
        ),
      ),
      body: Column(
        children: [
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
                  // 1. --- SECCIÓN OFENSIVA (Haces x2) ---
                  _buildInfoSection(
                    titulo: 'ATAQUE: Súper eficaz contra',
                    icono: Icons.bolt,
                    colorIcono: Colors.yellowAccent,
                    contenido: Wrap(
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
                    titulo: 'DEFENSA: Debil contra tipos',
                    icono: Icons.shield,
                    colorIcono: Colors.redAccent,
                    contenido: Wrap(
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
                    titulo: 'INMUNIDAD: inmune a los ataques de tipo ',
                    icono: Icons.shield_outlined,
                    colorIcono: Colors.white70,
                    contenido: Wrap(
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
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: myTypes.length,
              itemBuilder: (context, index) {
                final type = myTypes[index];
                final isSelected = (firstType == type || secondType == type);
                final textColor =
                    (type.name == 'Eléctrico' || type.name == 'Hielo')
                        ? Colors.black
                        : Colors.white;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type.color,
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.white,
                    side:
                        isSelected
                            ? const BorderSide(color: Colors.white, width: 3)
                            : BorderSide.none,
                  ),
                  onPressed: () {
                    setState(() {
                      if (firstType == type) {
                        firstType = null;
                      } else if (secondType == type) {
                        secondType = null;
                      } else if (firstType == null) {
                        firstType = type;
                      } else {
                        secondType ??= type;
                      }
                    });
                  },
                  child: FittedBox(
                    // 👈 Esto hace que el texto se encoja si no cabe
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        type.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
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
    );
  }

  // WIDGET AUXILIAR: Crea las tarjetas de información (Ataque/Defensa)
  Widget _buildInfoSection({
    required String titulo,
    required IconData icono,
    required Color colorIcono,
    required Widget contenido,
  }) {
    return Container(
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
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          contenido,
        ],
      ),
    );
  }

  // WIDGET AUXILIAR: Las tarjetas de arriba (Seleccionados)
  Widget _buildSelectedTypeCard(PokemonType? type) {
    return Container(
      width: 110,
      height: 45,
      decoration: BoxDecoration(
        color: type?.color ?? Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        type?.name ?? '---',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
