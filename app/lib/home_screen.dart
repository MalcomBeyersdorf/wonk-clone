import 'package:app/coffe_shop_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:pocketbase/pocketbase.dart';

class CoffeeShop {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  CoffeeShop({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class HomeScreen extends StatefulWidget {
  final PocketBase pb;

  const HomeScreen({super.key, required this.pb});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<CoffeeShop> _coffeeShops = [];
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffe shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewCoffeeShop,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              widget.pb.authStore.clear();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(0, 0), // Coordenadas iniciales
          initialZoom: 3.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _coffeeShops
                .map((shop) => Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(shop.latitude, shop.longitude),
                      child: GestureDetector(
                        onTap: () {
                          _showCoffeeShopDetails(shop);
                        },
                        child: const Icon(
                          Icons.local_cafe,
                          color: Colors.brown,
                          size: 40.0,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCoffeeShops();
  }

  void _addNewCoffeeShop() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CoffeeShopRegisterScreen(pb: widget.pb),
          ),
        )
        .then((_) => _fetchCoffeeShops());
  }

  // NOTE: Este metodo podria ir a un service/repository
  Future<void> _fetchCoffeeShops() async {
    try {
      final response = await widget.pb.collection('coffeShop').getList(
            page: 1,
            perPage: 50,
          );

      final List<CoffeeShop> shops = [];
      for (var record in response.items) {
        try {
          List<Location> locations =
              await locationFromAddress(record.data['address']);
          if (locations.isNotEmpty) {
            shops.add(CoffeeShop(
              id: record.id,
              name: record.data['name'],
              address: record.data['address'],
              latitude: locations.first.latitude,
              longitude: locations.first.longitude,
            ));
          }
        } catch (e) {
          print('Error geocodificando ${record.data['name']}: $e');
        }
      }

      setState(() {
        _coffeeShops = shops;
      });
    } catch (e) {
      print('Error al obtener cafeterías: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las cafeterías')),
      );
    }
  }

  void _showCoffeeShopDetails(CoffeeShop shop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(shop.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dirección: ${shop.address}'),
              const SizedBox(height: 10),
              Text('Latitud: ${shop.latitude}'),
              Text('Longitud: ${shop.longitude}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
