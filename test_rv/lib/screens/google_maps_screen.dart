import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class GoogleMapsScreen extends StatefulWidget {
  static String routeName = "/MapsScreen";

  final LatLng? selectedLatLng;
  final String initialAddress;

  GoogleMapsScreen({
    Key? key,
    this.selectedLatLng = const LatLng(33.5731251, -7.592403),
    required this.initialAddress,
  }) : super(key: key);

  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _launchNavigation(widget.initialAddress);
  }

  void _launchNavigation(String address) async {
    if (address.isNotEmpty) {
      String encodedAddress = Uri.encodeComponent(address);
      String mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress';
      if (await canLaunch(mapsUrl)) {
        await launch(mapsUrl);
      } else {
        print("Cannot launch the maps URL: $mapsUrl");
        _showSnackBar('Cannot launch navigation.');
      }
    } else {
      print("Address is empty, cannot launch navigation.");
      _showSnackBar('Please enter an address.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
              CameraPosition(target: widget.selectedLatLng!, zoom: 13),
              markers: Set<Marker>.from([
                Marker(
                  markerId: MarkerId("selectedLocation"),
                  position: widget.selectedLatLng!,
                ),
              ]),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Back ICon",
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.initialAddress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}