import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Búsqueda de Pokémon y Equipo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> teamMembers = [
    {'name': '193243 Moisés de Jesús Anzueto González', 'phone': '5551234567'},
    {'name': '201236 Miguel Ángel Tovar Reyes', 'phone': '5557654321'},
    {'name': '201244 Alfredo de Jesús Borraz Juárez', 'phone': '5559876543'},
  ];

  String searchQuery = '';
  String pokemonName = '';
  String pokemonId = '';
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;
  bool hasError = false;

  final String apiUrl = 'https://your-backend-url/api';

  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          pokemonData = null;
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        pokemonData = null;
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> createPokemon(Map<String, dynamic> newPokemon) async {
    final url = Uri.parse('$apiUrl/pokemon');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(newPokemon));

    if (response.statusCode == 201) {
      print('Pokémon creado exitosamente.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pokémon creado exitosamente.')));
    } else {
      print('Error al crear el Pokémon.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al crear el Pokémon.')));
    }
  }

  Future<void> updatePokemon(
      String id, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$apiUrl/pokemon/$id');
    final response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedData));

    if (response.statusCode == 200) {
      print('Pokémon actualizado exitosamente.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pokémon actualizado exitosamente.')));
    } else {
      print('Error al actualizar el Pokémon.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el Pokémon.')));
    }
  }

  Future<void> deletePokemon(String id) async {
    final url = Uri.parse('$apiUrl/pokemon/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Pokémon eliminado exitosamente.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pokémon eliminado exitosamente.')));
    } else {
      print('Error al eliminar el Pokémon.');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el Pokémon.')));
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'No se pudo realizar la llamada a $phoneNumber';
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent('¡Hola desde la app!'),
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'No se pudo abrir la aplicación de mensajes para $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipo y Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Integrantes del equipo:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  final member = teamMembers[index];
                  return Card(
                    child: ListTile(
                      title: Text(member['name']!),
                      subtitle: Text('Teléfono: ${member['phone']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.call),
                            onPressed: () => _makePhoneCall(member['phone']!),
                          ),
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () => _sendMessage(member['phone']!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                pokemonName = value.toLowerCase();
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'ID del Pokémon (para actualizar/eliminar)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                pokemonId = value;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (pokemonName.isNotEmpty) {
                        fetchPokemon(pokemonName);
                      }
                    },
                    child: Text('Buscar Pokémon'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (pokemonName.isNotEmpty) {
                        createPokemon({'name': pokemonName});
                      }
                    },
                    child: Text('Crear Pokémon'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (pokemonId.isNotEmpty) {
                        updatePokemon(pokemonId, {'name': pokemonName});
                      }
                    },
                    child: Text('Actualizar Pokémon'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (pokemonId.isNotEmpty) {
                        deletePokemon(pokemonId);
                      }
                    },
                    child: Text('Eliminar Pokémon'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : pokemonData != null
                    ? Column(
                        children: [
                          Text(
                            pokemonData!['name'].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.network(
                            pokemonData!['sprites']['front_default'],
                            height: 150,
                            width: 150,
                          ),
                          Text('Peso: ${pokemonData!['weight']}'),
                          Text('Altura: ${pokemonData!['height']}'),
                          Text(
                              'Tipo: ${pokemonData!['types'][0]['type']['name']}'),
                        ],
                      )
                    : hasError
                        ? Text(
                            'No se encontró el Pokémon. Verifica el nombre.',
                            style: TextStyle(color: Colors.red),
                          )
                        : Text('Introduce un nombre y realiza la búsqueda.'),
          ],
        ),
      ),
    );
  }
}
