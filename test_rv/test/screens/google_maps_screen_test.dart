// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:test_rv/components/size_config.dart';
// import 'package:test_rv/screens/google_maps_screen.dart';
//
// // Mock implementation of SizeConfig
// class MockSizeConfig extends Mock implements SizeConfig {}
//
// class MockGoogleMapController extends Mock implements GoogleMapController {}
//
// void main() {
//   late MockGoogleMapController mockMapController;
//   late MockSizeConfig mockSizeConfig;
//
//   setUp(() {
//     mockMapController = MockGoogleMapController();
//     mockSizeConfig = MockSizeConfig();
//     SizeConfig.init(null); // Initialize SizeConfig with a dummy context
//   });
//
//   testWidgets('GoogleMapsScreen renders correctly', (WidgetTester tester) async {
//     // Mock the SizeConfig methods
//     when(() => mockSizeConfig.getProportionateScreenHeight(any(named: 'inputHeight'))).thenReturn(200);
//     when(() => mockSizeConfig.getProportionateScreenWidth(any(named: 'inputWidth'))).thenReturn(300);
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: GoogleMapsScreen(initialAddress: ''),
//         ),
//       ),
//     );
//
//     // Verify that the GoogleMap widget is displayed
//     expect(find.byType(GoogleMap), findsOneWidget);
//     // Verify that the search field is displayed
//     expect(find.byType(TextField), findsOneWidget);
//   });
//
//   testWidgets('GoogleMapsScreen displays selected location marker', (WidgetTester tester) async {
//     // Mock the location coordinates
//     final initialLocation = LatLng(40.7128, -74.0060);
//
//     // Mock the SizeConfig methods
//     when(() => mockSizeConfig.getProportionateScreenHeight(any(named: 'inputHeight'))).thenReturn(200);
//     when(() => mockSizeConfig.getProportionateScreenWidth(any(named: 'inputWidth'))).thenReturn(300);
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: GoogleMapsScreen(initialAddress: ''),
//         ),
//       ),
//     );
//
//     final googleMapWidget = find.byType(GoogleMap);
//     expect(googleMapWidget, findsOneWidget);
//
//     // Get the GoogleMap widget
//     final googleMap = tester.widget<GoogleMap>(googleMapWidget);
//
//     // Trigger onMapCreated callback manually with mock controller
//     googleMap.onMapCreated!(mockMapController);
//
//     // Expect the marker to be added to the map
//     expect(googleMap.markers.length, equals(1));
//     expect(googleMap.markers.first.markerId, equals(MarkerId('selectedLocation')));
//     expect(googleMap.markers.first.position, equals(initialLocation));
//   });
// }