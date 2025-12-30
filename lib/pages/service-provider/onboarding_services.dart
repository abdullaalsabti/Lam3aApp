import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:lamaa/models/provider_service.dart';
import 'package:lamaa/providers/providerServices_provider.dart';
import 'package:lamaa/services/api_service.dart';
import '../../providers/sign_up_providers.dart';
import '../../widgets/button.dart';

class OnBoardingServices extends ConsumerStatefulWidget {
  final bool isOnboarding;
  final ProviderService? service;

  const OnBoardingServices({super.key, this.isOnboarding = true, this.service});

  @override
  ConsumerState<OnBoardingServices> createState() => _OnBoardingServicesState();
}

class _OnBoardingServicesState extends ConsumerState<OnBoardingServices> {
  bool loadingCategories = false;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _estTimeController = TextEditingController();
  final TextEditingController _servDescController = TextEditingController();
  static const baseEndpoint = "provider/services";

  String? categoryId;
  var apiService = ApiService();
  String? errorMessage;
  List<Category> categories = [];
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.service != null;
    if (isEditing) {
      _priceController.text = widget.service!.price.toString();
      _estTimeController.text = widget.service!.estimatedTime.toString();
      _servDescController.text = widget.service!.description.toLowerCase();
      categoryId = widget.service!.categoryId;
    }
    fetchCategories(); // ✅ Fetch categories when widget loads
  }

  void _onEdit(ProviderService newService) async {
    try {
      if (widget.service!.serviceId != null) {

        final id = widget.service!.serviceId;
        final endpoint = "$baseEndpoint/$id";
        final res = await apiService.putAuthenticated(endpoint,newService.toJson(),);

        if (res.statusCode == 200) {
          ref.invalidate(providerServiceProvider);
          _showSnackbar("service editted succfully");
          Navigator.of(context).pop();
        } else {
          _showSnackbar("service failed to edit ");
        }
      }
    } catch (ex) {
      _showSnackbar("service failed to edit $ex");
    }
  }

  //fetch categories from backend
  void fetchCategories() async {
    setState(() {
      loadingCategories = true; // ✅ START loading
      errorMessage = null;
      categories.clear(); // ✅ prevent duplicates
    });

    try {
      const endpoint = "$baseEndpoint/categories";
      final res = await apiService.getAuthenticated(endpoint);

      if (res.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(res.body) as List<dynamic>;

        final loadedCategories = decoded.map((category) {
          return Category(id: category["id"], name: category["name"]);
        }).toList();

        setState(() {
          categories = loadedCategories; // ✅ assign, not mutate
        });
      } else {
        setState(() {
          errorMessage =
              jsonDecode(res.body)["error"] ?? "Failed to load categories";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load categories";
      });
    } finally {
      setState(() {
        loadingCategories = false; // ✅ END loading
      });
    }
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _addService(ProviderService service) async {
    try {
      String postServiceEndpoint = "provider/services";
      Response res = await apiService.postAuthenticated(
        postServiceEndpoint,
        service.toJson(),
      );

      if (res.statusCode == 200) {
        _showSnackbar("service added succesfuly");

        // Handle navigation based on context
        if (widget.isOnboarding) {
          // During signup: go to availability page
          Navigator.pushNamed(context, "/provider_availability");
        } else {
          // When logged in: go back to main page or pop
          Navigator.of(context).pop();
        }
      } else if (res.statusCode == 404) {
        _showSnackbar("category not found");
      }
    } catch (ex) {
      _showSnackbar("faliled to submit a service");
    }
  }

  bool _submitForm() {
    if (_formKey.currentState!.validate()) {
      final price = _priceController.text;
      final estTime = _estTimeController.text;
      final servDesc = _servDescController.text;

      final notifier = ref.read(signupProvider.notifier);

      notifier.updateServicePrice(price);
      notifier.updateEstServiceTime(estTime);
      notifier.updateServiceDesc(servDesc);

      ProviderService service = ProviderService(
        categoryId: categoryId!,
        description: servDesc,
        price: double.parse(price),
        estimatedTime: int.parse(estTime),
      );
      isEditing ? _onEdit(service) : _addService(service);

      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);
    final theme = Theme.of(context);
    Widget content;
    if (loadingCategories == false) {
      content = DropdownButtonFormField<String>(
        value: categoryId,
        initialValue: isEditing ? widget.service!.categoryId : null,
        isExpanded:
            true, // Prevents overflow by making dropdown take full width
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        hint: Text('Select Service', style: GoogleFonts.poppins(fontSize: 15)),
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis, // Handle long category names
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            categoryId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please choose a service';
          }
          return null;
        },
      );
    } else {
      content = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? "Edit Your Services" : "Add Your Service", style: theme.textTheme.titleLarge!.copyWith(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                "Select a service you provide*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              //select a category
              const SizedBox(height: 10),
              errorMessage != null
                  ? Text(errorMessage!, style: TextStyle(color: Colors.red))
                  : content,

              const SizedBox(height: 20),
              //price fo the service
              Text(
                "Price of your service*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'JD',
                  suffixStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) < 0) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Estimated time to finish service*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _estTimeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'min',
                  suffixStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Please enter an estimated time';
                  }
                  if (int.parse(value) <= 0) {
                    return 'minutes should be more than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Description of the service",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _servDescController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value){
                  if(value == null || value.trim().isEmpty){
                    return "you should add description for your service";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // reduced space for better layout
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Button(
            btnText: widget.isOnboarding
                ? 'Save & Continue'
                : isEditing
                ? 'Edit Service'
                : 'Add Service',
            onTap: () {
              _submitForm();
            },
          ),
        ),
      ),
    );
  }
}

class Category {
  String name;
  String id;
  Category({required this.id, required this.name});
}
