import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:openhaystack_mobile/accessory/accessory_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:openhaystack_mobile/history/days_selection_slider.dart';
import 'package:openhaystack_mobile/history/location_popup.dart';

class AccessoryHistory extends StatefulWidget {
  Accessory accessory;

  /// Shows previous locations of a specific [accessory] on a map.
  /// The locations are connected by a chronological line.
  /// The number of days to go back can be adjusted with a slider.
  AccessoryHistory({
    Key? key,
    required this.accessory,
  }) : super(key: key);

  @override
  _AccessoryHistoryState createState() => _AccessoryHistoryState();
}

class _AccessoryHistoryState extends State<AccessoryHistory> {
  final MapController _mapController = MapController();

  bool showPopup = false;
  Pair<LatLng, DateTime>? popupEntry;

  double numberOfDays = 7;

  void _fitToHistory() {
    final historicLocations =
        widget.accessory.locationHistory.map((entry) => entry.a).toList();
    if (historicLocations.isEmpty) {
      return;
    }

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: historicLocations,
        padding: const EdgeInsets.all(25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter for the locations after the specified cutoff date (now - number of days)
    var now = DateTime.now();
    List<Pair<LatLng, DateTime>> locationHistory =
        widget.accessory.locationHistory
            .where(
              (element) => element.b.isAfter(
                now.subtract(Duration(days: numberOfDays.round())),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accessory.name),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(49.874739, 8.656280),
                  initialZoom: 13.0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.flingAnimation |
                        InteractiveFlag.pinchMove,
                  ),
                  onTap: (_, __) {
                    setState(() {
                      showPopup = false;
                      popupEntry = null;
                    });
                  },
                  onMapReady: _fitToHistory,
                ),
                children: [
                  TileLayer(
                    tileBuilder: (context, child, tile) {
                      var isDark =
                          (Theme.of(context).brightness == Brightness.dark);
                      return isDark
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1,
                                0,
                                0,
                                0,
                                255,
                                0,
                                -1,
                                0,
                                0,
                                255,
                                0,
                                0,
                                -1,
                                0,
                                255,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: child,
                            )
                          : child;
                    },
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'de.seemoo.openhaystack_mobile',
                  ),
                  RichAttributionWidget(
                    showFlutterMapAttribution: false,
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () async {
                          await launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright'),
                          );
                        },
                      ),
                    ],
                  ),
                  // The line connecting the locations chronologically
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points:
                            locationHistory.map((entry) => entry.a).toList(),
                        strokeWidth: 4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  // The markers for the historic locaitons
                  MarkerLayer(
                    markers: locationHistory
                        .map((entry) => Marker(
                              point: entry.a,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showPopup = true;
                                    popupEntry = entry;
                                  });
                                },
                                child: Icon(
                                  Icons.circle,
                                  size: 15,
                                  color: entry == popupEntry
                                      ? Colors.red
                                      : Theme.of(context).indicatorColor,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  // Displays the tooltip if active
                  MarkerLayer(
                    markers: [
                      if (showPopup)
                        LocationPopup(
                          location: popupEntry!.a,
                          time: popupEntry!.b,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: DaysSelectionSlider(
                numberOfDays: numberOfDays,
                onChanged: (double newValue) {
                  setState(() {
                    numberOfDays = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
