import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/service_category.dart';
import 'package:lamaa/providers/client_serviceRequest_provider.dart';

class AllServices extends ConsumerWidget {
  const AllServices({super.key, required this.services});
  final List<ServiceCategory> services;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Make it yours",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              //TODO: Integration with weathercaset API ,based on it , it will show when its good to wash the car
              const SizedBox(height: 5),
              Text(
                "Weather is perfect to service your vehicle",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              Text(
                "Partly cloudy with 0% chance of rain",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(
                        service.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Image.asset(
                        "lib/assets/images/washing.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // This widget will be shown if the image fails to load
                          return Icon(
                            Icons.local_car_wash,
                            size: 50,
                            color: scheme.primary
                          );
                        },
                      ),
                      trailing: service.averagePrice != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Avg. Price",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "${service.averagePrice!.toStringAsFixed(2)} JOD",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      onTap: () {
                        ref
                            .read(serviceRequestProvider.notifier)
                            .setCategory(service);
                        Navigator.pushNamed(context, '/date_time_selection');
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
