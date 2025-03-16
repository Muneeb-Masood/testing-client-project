import 'package:test/main.dart';
import 'package:test/networking/firestore_helper.dart';
import 'package:test/screens/customer/customer_main_screen.dart';
import 'package:test/utilities/constants.dart';
import 'package:test/utilities/custom_widgets/tailor_Card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haversine_distance/haversine_distance.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../models/tailor.dart';
import '../../utilities/custom_widgets/rectangular_button.dart';

class SearchTailor extends StatefulWidget {
  static const id = "/customer_home";

  const SearchTailor({super.key});
  @override
  _SearchTailorState createState() => _SearchTailorState();
}

class _SearchTailorState extends State<SearchTailor> {
  final FireStoreHelper firestorer = FireStoreHelper();
  List<SortBy> sortBy = [SortBy.nearYou];
  List<Tailor> tailors = [];
  List<Tailor> nearbyTailors = [];
  List<Tailor> allTailors = [];

  bool isLoadingTailors = false;
  String searchedTailorName = "";

  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTailors();
    Future.delayed(const Duration(milliseconds: 20)).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingOverlay(
      isLoading: appUser == null || isLoadingTailors,
      progressIndicator: kSpinner(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildSearchTextField(size),
                    buildAddFilterButton(size),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                    if (sortBy.isNotEmpty && sortBy.contains(SortBy.nearYou))
                      Text(
                        'Near you',
                        style:
                            kInputStyle.copyWith(color: Colors.grey.shade600),
                      ).tr(),
                  ],
                ),
              ),
              Column(
                children: tailors.isEmpty
                    ? [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              getTranslatedText(
                                  'اِس کیٹیگری میں کوئی درزی دستیاب نہیں ہے۔',
                                  'No tailors available in this category.'),
                              style: kTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ]
                    : List.generate(
                        tailors.length,
                        (index) {
                          return TailorCard(
                            tailor: tailors[index],
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

  loadTailors() async {
    toggleLoadingStatus();
    //Todo near by tailors should be in range of 0-20 kilometers
    nearbyTailors =
        await firestorer.loadTailorsOfCity(currentCustomer?.city ?? 'Jamshoro');
    firestorer.loadAllTailors().then((value) {
      allTailors = value;
      if (mounted) setState(() {});
    });
    sortNearBy();
    tailors = nearbyTailors;
    if (mounted) setState(() {});
    print("Tailors length: ${tailors.length}");
    toggleLoadingStatus();
  }

//25.3666667:lat,68.3666667:lon=>hyderabad

  sortLadiesOnly() {
    tailors = tailors
        .where((element) =>
            element.stitchingType == StitchingType.ladies ||
            element.stitchingType == StitchingType.both)
        .toList();
    if (mounted) setState(() {});
  }

  void sortAvailableToWork() {
    tailors = tailors.where((element) => element.availableToWork).toList();
    if (mounted) setState(() {});
  }

  sortGentsOnly() {
    tailors = tailors
        .where((element) =>
            element.stitchingType == StitchingType.gents ||
            element.stitchingType == StitchingType.both)
        .toList();
    if (mounted) setState(() {});
  }

  sortGentsLadiesBoth() {
    tailors = tailors
        .where((element) => element.stitchingType == StitchingType.both)
        .toList();
    if (mounted) setState(() {});
  }

  sortByRating() {
    tailors.sort((t1, t2) => t1.rating.compareTo(t2.rating) * -1);
    if (mounted) setState(() {});
  }

  sortNearBy() {
    final haversineDistance = HaversineDistance();
    nearbyTailors.sort((t1, t2) {
      final customerCord = Location(
          currentCustomer?.location.latitude ?? 25.430388,
          currentCustomer?.location.longitude ?? 68.280863);
      final tailor1Cord = Location(
          t1.location.latitude, //?? 25.3666667,
          t1.location.longitude); // ?? 68.3666667);
      final tailor2Cord = Location(
          t2.location.latitude, //?? 25.3666667,
          t2.location.longitude); // ?? 68.3666667);

      final dist1 = haversineDistance
          .haversine(customerCord, tailor1Cord, Unit.METER)
          .floor();
      final dist2 = haversineDistance
          .haversine(customerCord, tailor2Cord, Unit.METER)
          .floor();
      // print(dist1.compareTo(dist2));
      return dist1.compareTo(dist2);
    });
  }

  void toggleLoadingStatus() {
    if (mounted) {
      setState(() {
        isLoadingTailors = !isLoadingTailors;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchFieldController.dispose();
  }

  onTailorSearch(String val) {
    if (mounted) {
      if (val.isNotEmpty) {
        searchedTailorName = val;
        tailors = tailors
            .where((element) =>
                element.tailorName
                    .toLowerCase()
                    .contains(searchedTailorName.toLowerCase()) ||
                element.shop!.name
                    .toLowerCase()
                    .contains(searchedTailorName.toLowerCase()))
            .toList();
      } else {
        tailors = sortBy.contains(SortBy.nearYou) ? nearbyTailors : allTailors;
      }
      setState(() {});
      // print(searchedTailorName);
    }
  }

  Widget buildAddFilterButton(Size size) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Card(
              color: kSkinColor,
              margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
                vertical: size.height * 0.21,
              ),
              child: StatefulBuilder(builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        SortBy.values.length,
                        (index) => CheckboxListTile(
                          activeColor: kOrangeColor,
                          value: sortBy.contains(SortBy.values[index]),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            capitalizeText(
                                spaceSeparatedText(SortBy.values[index].name)),
                            style: kInputStyle,
                          ).tr(),
                          onChanged: (val) {
                            sortBy.contains(SortBy.values[index])
                                ? sortBy.remove(SortBy.values[index])
                                : sortBy.add(SortBy.values[index]);
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.1),
                        child: RectangularRoundedButton(
                          padding: EdgeInsets.zero,
                          buttonName: 'Done',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          );
          tailors =
              sortBy.contains(SortBy.nearYou) ? nearbyTailors : allTailors;
          if (sortBy.contains(SortBy.availableToWork)) {
            sortAvailableToWork();
          }
          if (sortBy.contains(SortBy.ladiesTailor)) sortLadiesOnly();
          if (sortBy.contains(SortBy.gentsTailor)) sortGentsOnly();
          if (sortBy.contains(SortBy.ladiesTailor) &&
              sortBy.contains(SortBy.gentsTailor)) {
            sortGentsLadiesBoth();
          }
          if (sortBy.contains(SortBy.nearYou) && sortBy.length == 1) {
            tailors = nearbyTailors;
          }
          if (sortBy.contains(SortBy.rating)) {
            sortByRating();
          }
          if (mounted) setState(() {});
        },
        child: Text(
          'Add filter',
          style: reminderButtonStyle,
        ).tr(),
      ),
    );
  }

  buildSearchTextField(Size size) {
    return TextField(
      controller: searchFieldController,
      decoration: kTextFieldDecoration.copyWith(
        contentPadding: EdgeInsets.zero,
        hintText: getTranslatedText("درزی تلاش کریں", 'search a tailor'),
        hintStyle: kInputStyle,
        suffixIcon: IconButton(
          icon: const Icon(FontAwesomeIcons.xmark, size: 18),
          onPressed: () {
            searchFieldController.clear();
            tailors = nearbyTailors;
            if (mounted) setState(() {});
          },
        ),
        prefixIcon: const Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 15,
          // color: Colors.grey,
        ),
      ),
      onChanged: onTailorSearch,
      onSubmitted: onTailorSearch,
    );
  }
}

enum SortBy {
  nearYou,
  gentsTailor,
  ladiesTailor,
  availableToWork,
  rating,
}
