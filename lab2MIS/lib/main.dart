import 'package:flutter/material.dart';

enum ClothingType { Blouses, Trousers, Underwear, Other }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Clothing App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ClothingItem> clothingItems = [];
  ClothingType selectedType = ClothingType.Blouses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(widget.title),
      ),
      backgroundColor: Colors.lightGreen,
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(width: 2, color: Colors.black),
          primary: Colors.green,
        ),
        onPressed: () {
          _showAddPopup(context);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            for (int index = 0; index < clothingItems.length; index++)
              Card(
                child: ListTile(
                  textColor: Colors.red,
                  title: Text(clothingItems[index].itemName),
                  subtitle: Text(
                    clothingItems[index].clothingType != ClothingType.Other
                        ? clothingItems[index].clothingType.toString().split('.')[1]
                        : 'Other',
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        color: Colors.green,
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditPopup(context, index);
                        },
                      ),
                      IconButton(
                        color: Colors.green,
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteClothingItem(index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16.0), // Adjust the spacing between cards
          ],
        ),
      ),
    );
  }


  void _showAddPopup(BuildContext context) {
    TextEditingController clothingItemController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Clothing Item', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: clothingItemController,
                  decoration: InputDecoration(
                    labelText: 'Clothing Item',
                    labelStyle: TextStyle(color: Colors.blue), // Set label text color
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildClothingTypeList(context),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                String newItem = clothingItemController.text;
                if (newItem.isNotEmpty) {
                  setState(() {
                    clothingItems.insert(
                      0,
                      ClothingItem(itemName: newItem, clothingType: selectedType),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }


  void _showEditPopup(BuildContext context, int index) {
    TextEditingController clothingItemController =
    TextEditingController(text: clothingItems[index].itemName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Clothing Item', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: clothingItemController,
                  decoration: InputDecoration(
                    labelText: 'Clothing Item',
                    labelStyle: TextStyle(color: Colors.blue), // Set label text color
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildClothingTypeList(context),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                String editedItem = clothingItemController.text;
                if (editedItem.isNotEmpty) {
                  setState(() {
                    clothingItems[index].itemName = editedItem;
                    clothingItems[index].clothingType = selectedType;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClothingTypeList(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Clothing Type:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10.0),
            _buildClothingTypeTile(context, ClothingType.Blouses, setState),
            _buildClothingTypeTile(context, ClothingType.Trousers, setState),
            _buildClothingTypeTile(context, ClothingType.Underwear, setState),
            _buildClothingTypeTile(context, ClothingType.Other, setState),
          ],
        );
      },
    );
  }


  Widget _buildClothingTypeTile(
      BuildContext context,
      ClothingType type,
      StateSetter setState,
      ) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Row(
        children: [
          Checkbox(
            value: selectedType == type,
            onChanged: (bool? value) {
              setState(() {
                if (value != null && value) {
                  selectedType = type;
                } else {
                  selectedType = ClothingType.Other; // Deselect if unchecked
                }
              });
            },
          ),
          const SizedBox(width: 8.0),
          Text(
            type != ClothingType.Other
                ? type.toString().split('.')[1]
                : 'Other',
          ),
        ],
      ),
    );
  }





  void _deleteClothingItem(int index) {
    setState(() {
      clothingItems.removeAt(index);
    });
  }
}

class ClothingItem {
  String itemName;
  ClothingType clothingType;

  ClothingItem({required this.itemName, required this.clothingType});
}
