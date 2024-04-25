import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/size_config.dart';

class GoogleMapsScreen extends StatefulWidget {
  static String routeName = "/MapsScreen";

  late final LatLng? selectedLatLng;
  final TextEditingController? addressController;

  GoogleMapsScreen({
    Key? key,
    this.selectedLatLng = const LatLng(33.5731251, -7.592403),
    this.addressController,
  }) : super(key: key);

  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  List<Location> _suggestions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setInitialSearchText().then((_) {
      // Ensuring the controller has text, and the text is a complete address
      if (_searchController.text.isNotEmpty) {
        // A short delay can sometimes help with timing issues
        Future.delayed(Duration(seconds: 1), () {
          print("Launching navigation for address: ${_searchController.text}");
          _launchNavigation();
        });
      } else {
        print("No address available to launch navigation upon init.");
      }
    });
  }

  Future<void> _setInitialSearchText() async {
    String formattedAddress =
        await _formatAddressFromLatLng(widget.selectedLatLng!);
    setState(() {
      _searchController.text = formattedAddress;
    });
  }

  void _launchNavigation() async {
    String address = _searchController.text;
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
                  Expanded(child: _buildSuggestionsDropdown()),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70.0),
                child: SizedBox(
                  width: double.infinity,
                  height: getProportionateScreenHeight(45),
                  child: TextButton(
                    onPressed: _launchNavigation,
                    child: Text('Start Navigation'),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onSearchSubmitted(String value) async {
    List<Location> locations = await locationFromAddress(value);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      String formattedAddress = await _formatLocation(location);
      setState(() {
        widget.selectedLatLng = LatLng(location.latitude, location.longitude);
        _searchController.text = formattedAddress;
      });
      _mapController
          ?.animateCamera(CameraUpdate.newLatLng(widget.selectedLatLng!));
    }
  }

  void _saveLocation() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied) {
        _showSnackBar('Location permission denied.');
        return;
      }
    }

    if (widget.selectedLatLng != const LatLng(33.5731251, -7.592403)) {
      String formattedAddress =
          await _formatAddressFromLatLng(widget.selectedLatLng!);
      if (widget.addressController != null) {
        widget.addressController!.text = formattedAddress;
      }
      _showSnackBar('Location saved: $formattedAddress');
    } else {
      _showSnackBar('Please select a location.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSearchChanged(String value) async {
    List<Location> locations = await locationFromAddress(value);
    setState(() {
      _suggestions = locations;
    });
  }

  Widget _buildSuggestionsDropdown() {
    return TypeAheadField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        onChanged: _onSearchChanged,
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: 'Enter your location',
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _onSearchSubmitted(_searchController.text);
            },
          ),
          contentPadding: const EdgeInsets.only(left: 20, bottom: 5, right: 5),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 1.5),
          ),
        ),
      ),
      suggestionsCallback: (pattern) => _getFormattedSuggestions(pattern),
      itemBuilder: (context, String suggestion) {
        return ListTile(title: Text(suggestion));
      },
      onSuggestionSelected: (String selectedSuggestion) {
        _searchController.text = selectedSuggestion;
        _onSearchSubmitted(selectedSuggestion);
      },
    );
  }

  Future<List<String>> _getFormattedSuggestions(String pattern) async {
    List<Location> locations = await locationFromAddress(pattern);
    List<String> suggestions = [];

    for (var location in locations) {
      String formattedLocation = await _formatLocation(location);
      suggestions.add(formattedLocation);
    }

    return suggestions;
  }

  Future<String> _formatLocation(Location location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = placemark.street ?? '';
        if (placemark.subLocality != null) {
          address += ', ' + placemark.subLocality!;
        }
        if (placemark.locality != null) {
          address += ', ' + placemark.locality!;
        }
        if (placemark.administrativeArea != null) {
          address += ', ' + placemark.administrativeArea!;
        }
        if (placemark.country != null) {
          address += ', ' + placemark.country!;
        }
        return address;
      }
    } catch (e) {
      print('Error formatting location: $e');
    }

    return 'Location not found';
  }

  Future<String> _formatAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = placemark.street ?? '';
        if (placemark.subLocality != null) {
          address += ', ' + placemark.subLocality!;
        }
        if (placemark.locality != null) {
          address += ', ' + placemark.locality!;
        }
        if (placemark.administrativeArea != null) {
          address += ', ' + placemark.administrativeArea!;
        }
        if (placemark.country != null) {
          address += ', ' + placemark.country!;
        }
        return address;
      }
    } catch (e) {
      print('Error formatting address: $e');
    }

    return 'Address not found';
  }
}
