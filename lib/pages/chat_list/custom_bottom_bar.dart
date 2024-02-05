import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tawkie/pages/chat_list/models/filters_tawkie.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: Theme.of(context).colorScheme.background, // Background color
      child: Row(
        children: [
          // ListView.builder for existing filter list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filtersTawkie.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        filtersTawkie[index].icon,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed circle on right for filter parameters
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: (){
                // Navigate to FiltersListSetting
                context.go('/rooms/filters_list_setting');
              },
              child:             Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
