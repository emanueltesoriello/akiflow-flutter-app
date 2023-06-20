import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/src/base/ui/widgets/base/bordered_input_view.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:uuid/uuid.dart';

class AddLocationModal extends StatefulWidget {
  final String? initialLocation;
  final Function(String contact) updateLocation;
  const AddLocationModal({super.key, required this.updateLocation, required this.initialLocation});

  @override
  State<AddLocationModal> createState() => _AddLocationModalState();
}

class _AddLocationModalState extends State<AddLocationModal> {
  final FocusNode searchFocus = FocusNode();
  Timer? debounce;
  List<String>? searchedLocation;
  var uuid = const Uuid();
  late String _sessionToken;
  List<dynamic> _placeList = [];

  @override
  void initState() {
    searchFocus.requestFocus();
    debounce?.cancel();
    searchedLocation = [];
    _sessionToken = uuid.v4();
    super.initState();
  }

  @override
  void dispose() {
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsExt.background(context),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(Dimension.padding),
          child: ListView(
            shrinkWrap: true,
            children: [
              const ScrollChip(),
              const SizedBox(height: Dimension.padding),
              Text(t.event.editEvent.addLocationModal.addLocation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey800(context),
                      )),
              const SizedBox(height: Dimension.padding),
              BorderedInputView(
                focus: searchFocus,
                hint: t.event.editEvent.addLocationModal.search,
                initialValue: widget.initialLocation,
                onChanged: (value) {
                  _searchLocation(value);
                },
              ),
              if (searchedLocation != null)
                SizedBox(
                  height: 210,
                  child: ListView.builder(
                    itemCount: searchedLocation!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          widget.updateLocation(searchedLocation!.elementAt(index));
                          Navigator.of(context).pop();
                        },
                        child: LocationRow(locationName: searchedLocation!.elementAt(index)),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _searchLocation(String input) async {
    String placesApiKey =
        Platform.isIOS ? Config.googlePlacesCredentials.iosApiKey : Config.googlePlacesCredentials.androidApiKey;
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$placesApiKey&sessiontoken=$_sessionToken';
    var response = await http.post(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        searchedLocation = [];
        searchedLocation!.add(input);
        _placeList = json.decode(response.body)['predictions'];
        for (var element in _placeList) {
          searchedLocation!.add(element['description']);
        }
      });
    } else {
      throw Exception('Failed to load predictions: ${jsonDecode(response.body)}');
    }
  }
}

class LocationRow extends StatelessWidget {
  final String? locationName;
  const LocationRow({
    super.key,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimension.paddingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: Dimension.defaultIconSize,
            width: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.mapSVG,
              color: ColorsExt.grey800(context),
            ),
          ),
          const SizedBox(width: Dimension.paddingS),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(locationName ?? '',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey800(context),
                          )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
