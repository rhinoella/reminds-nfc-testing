import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminds_flutter/src/dispense/dispense.dart';
import 'package:reminds_flutter/src/main/main_bloc.dart';

class RemindsMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemindsBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ReMINDS',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.purple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0), // Adds padding around buttons
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 40),
                  child: SizedBox(
                    width: double.infinity, // Make the button fill width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DispenseScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: Colors.purple, size: 30), // Dispense icon
                          SizedBox(width: 10),
                          Text(
                            "Dispense",
                            style:
                                TextStyle(fontSize: 20, color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: SizedBox(
                    width: double.infinity, // Make the button fill width
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login,
                              color: Colors.purple, size: 30), // Return icon
                          SizedBox(width: 10),
                          Text(
                            "Return",
                            style:
                                TextStyle(fontSize: 20, color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
