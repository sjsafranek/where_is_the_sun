import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
//import 'package:flutter_map_location/flutter_map_location.dart';
//import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:where_is_the_sun/shared/cached_tile_provider.dart';

Future<Position> getPosition() async {
  print("BEFORE");
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print("AFTER");
  return position;
}


Future<Position> getPositionTest() async {
  await Future.delayed(Duration(seconds: 3));
  return Position(longitude: 10.0, latitude: 10.0, timestamp: DateTime.now(), accuracy: 1.0, altitude: 0.0, heading: 0.0, speed: 0.0, speedAccuracy: 0.0);
}


class MapWidget extends StatefulWidget {
  const MapWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {

  final MapController mapController = MapController();
  Future<Position> position = getPositionTest();
  double longitude = 0.0;
  double latitude = 0.0;

  // @override
  // void initState() {
  //   super.initState();
  //   this.position = getPositionTest();
  // }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: position,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print('Data of Snapshot ${snapshot.data}');

          if (snapshot.hasData) {
            LatLng value = snapshot.data;
            if (null != value.longitude) {
              this.longitude = value.longitude;
            }
            if (null != value.latitude) {
              this.latitude = value.latitude;
            }
            return Center(child: Text("$longitude,$latitude"));
          }

          return CircularProgressIndicator();

          return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(latitude, longitude),
                zoom: 13.0,
                plugins: [],
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  // attributionBuilder: (_) {
                  //   return Text("© OpenStreetMap contributors");
                  // },
                  tileProvider: const CachedTileProvider(),
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(latitude, longitude),
                      builder: (ctx) =>
                          Container(
                            child: FlutterLogo(),
                          ),
                    ),
                  ],
                )
              ]
          );
        });
  }
}
