import 'package:test/utilities/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExpandableListTile extends StatelessWidget {
  const ExpandableListTile({
    Key? key,
    this.initiallyExpanded = false,
    required this.listTitle,
    required this.childList,
    required this.onChildListItemPressed,
    this.onExpanded,
  }) : super(key: key);
  final bool initiallyExpanded;
  final Function(bool)? onExpanded;
  final String listTitle;
  final List<String> childList;
  final Function(String) onChildListItemPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 5,
        ),
        elevation: 1.0,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            listTitle,
            style: kBoldTextStyle(size: 13).copyWith(color: kOrangeColor),
          ).tr(),
          onExpansionChanged: onExpanded,
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              shrinkWrap: true,
              itemCount: childList.length,
              itemBuilder: (context, index2) => Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 5,
                ),
                elevation: 1.0,
                child: ListTile(
                  tileColor: kLightSkinColor,
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.02,
                  leading: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.042,
                    backgroundImage:
                        // (dressImages[childList[index2]]!
                        //         .contains("assets")
                        //     ?
                        AssetImage(dressImages[childList[index2]] as String),
                    // : NetworkImage(dressImages[childList[index2]] as String)
                    //     as ImageProvider),
                  ),
                  title: Text(
                    getCategory(childList[index2]),
                    style: kTextStyle.copyWith(
                        fontSize: 14,
                        locale: context.locale,
                        color: Colors.grey.shade600),
                  ).tr(),
                  trailing: const Icon(Icons.add),
                  onTap: () => onChildListItemPressed(childList[index2]),
                ),
              ),
            ),
          ],
        ));
  }
}
