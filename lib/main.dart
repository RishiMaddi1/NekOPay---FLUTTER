import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MaterialApp(
    home: TransactionApp(),
  ));
}

class TransactionApp extends StatefulWidget {
  @override
  _TransactionAppState createState() => _TransactionAppState();
}

class _TransactionAppState extends State<TransactionApp> {
  late SharedPreferences _prefs;
  final TransactionLinkedList _transactions = TransactionLinkedList();
  SortBy _sortBy = SortBy.none;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactionsJson = _prefs.getString('transactions');
      if (transactionsJson != null) {
        final List<dynamic> transactionsData = jsonDecode(transactionsJson);
        setState(() {
          _transactions.clear();
          for (var transactionData in transactionsData) {
            final transaction = Transaction(
              name: transactionData['name'],
              amount: transactionData['amount'],
              date: DateTime.parse(transactionData['date']),
            );
            _transactions.add(TransactionNode(transaction));
          }
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> _saveTransactions() async {
    try {
      final List<Map<String, dynamic>> transactionsData = _transactions.map((node) {
        final transaction = node.transaction;
        return {
          'name': transaction.name,
          'amount': transaction.amount,
          'date': transaction.date.toIso8601String(),
        };
      }).toList();
      final transactionsJson = jsonEncode(transactionsData);
      await _prefs.setString('transactions', transactionsJson);
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NekOPay',
          style: TextStyle(
            fontFamily: 'PoetsenOne',
            fontSize: 24, // Adjust the font size as needed
            fontWeight: FontWeight.bold, // Adjust the font weight as needed
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () => _sso(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _btas(),
          Expanded(
            child: SingleChildScrollView(
              child: _bt(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(context),
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add,color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _bt() {
    List<TransactionNode> sortedTransactions = _transactions.toList();
    if (_sortBy != SortBy.none) {
      sortedTransactions.sort((a, b) {
        switch (_sortBy) {
          case SortBy.name:
            return a.transaction.name.compareTo(b.transaction.name);
          case SortBy.amount:
            return a.transaction.amount.compareTo(b.transaction.amount);
          case SortBy.date:
            return a.transaction.date.compareTo(b.transaction.date);
          case SortBy.none:
            return 0;
        }
      });
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedTransactions.length,
      separatorBuilder: (context, inAVdex) => Divider(height: 0),
      itemBuilder: (BuildContext context, int index) {
        final transaction = sortedTransactions[index].transaction;
        final formattedDate = DateFormat('MMM d, yyyy').format(transaction.date);

        return Container(
          margin: EdgeInsets.all(8), // Adjust margin as needed
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the container
            borderRadius: BorderRadius.circular(8), // Rounded corners for the container
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 3, // Spread radius
                blurRadius: 5, // Blur radius
                offset: Offset(0, 3), // Offset of the shadow
              ),
            ],
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.name,
                      style: TextStyle(fontSize: 30, color: Colors.deepPurple,fontFamily: 'PoetsenOne'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Date: $formattedDate',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.currency_rupee),
                SizedBox(width: 5), // Adjust spacing between icon and amount
                Text(
                  '${transaction.amount}',

                  style: TextStyle(
                      fontFamily: 'PoetsenOne',
                      fontSize: 30,
                      color: Colors.deepPurple
                  ),// Adjust the size as needed
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _dtn(sortedTransactions[index]);
                  },
                ),
              ],
            ),
          ),
        );

      },
    );
  }

  Widget _btas() {
    double totalAmount = _ctotalAmt();
    String formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '\₹').format(totalAmount);
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      alignment: Alignment.center,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple, // Background color around the text
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      child: Text(
        'Amount Spent:\n$formattedAmount',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,fontFamily: 'PoetsenOne'), // Text color
      ),
    );
  }

  Future<void> _displayDialog(BuildContext context) async {
    String name = '';
    double amount = 0.0;
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Name'),
              TextField(
                decoration: InputDecoration(hintText: 'Enter name'),
                onChanged: (value) {
                  name = value;
                },
                maxLength: 12, // Limiting input to 13 characters
              ),
              SizedBox(height: 16),
              Text('Amount'),
              TextField(
                decoration: InputDecoration(hintText: 'Enter amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.parse(value);
                },
              ),
              SizedBox(height: 16),
              Text('Date'),
              TextButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Text(
                  DateFormat('MMM d, yyyy').format(selectedDate),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                final transaction = Transaction(
                  name: name,
                  amount: amount,
                  date: selectedDate,
                );
                setState(() {
                  _transactions.add(TransactionNode(transaction));
                  _saveTransactions(); // Save transactions
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }


  void _dtn(TransactionNode transactionNode) {
    setState(() {
      _transactions.remove(transactionNode);
      _saveTransactions(); // Save transactions
    });
  }

  void _sso(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Sort by Name'),
                onTap: () {
                  _sT(SortBy.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.sort),
                title: Text('Sort by Amount'),
                onTap: () {
                  _sT(SortBy.amount);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Sort by Date'),
                onTap: () {
                  _sT(SortBy.date);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sT(SortBy sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (_sortBy) {
        case SortBy.name:
          _transactions.sortByTransactionName();
          break;
        case SortBy.amount:
          _transactions.sortByTransactionAmount();
          break;
        case SortBy.date:
          _transactions.sortByTransactionDate();
          break;
        case SortBy.none:
          _transactions.clearSorting();
          break;
      }
    });
  }

  double _ctotalAmt() {
    double total = 0.0;
    for (var node in _transactions) {
      total += node.transaction.amount;
    }
    return total;
  }
}

class Transaction {
  final String name;
  final double amount;
  final DateTime date;

  Transaction({required this.name, required this.amount, required this.date});
}

final class TransactionNode extends LinkedListEntry<TransactionNode> {
  final Transaction transaction;

  TransactionNode(this.transaction);
}

enum SortBy { none, name, amount, date }

final class TransactionLinkedList extends LinkedList<TransactionNode> {
  // Additional methods for manipulating transactions can be implemented here

  // Method to sort transactions by name
  void sortByTransactionName() {
    // Convert linked list to a list for sorting
    List<TransactionNode> transactionsList = toList();
    transactionsList.sort((a, b) => a.transaction.name.compareTo(b.transaction.name));
    // Reconstruct the linked list with sorted elements
    clear();
    transactionsList.forEach((node) => add(node));
  }

  // Method to sort transactions by amount
  void sortByTransactionAmount() {
    // Convert linked list to a list for sorting
    List<TransactionNode> transactionsList = toList();
    transactionsList.sort((a, b) => a.transaction.amount.compareTo(b.transaction.amount));
    // Reconstruct the linked list with sorted elements
    clear();
    transactionsList.forEach((node) => add(node));
  }

  // Method to sort transactions by date
  void sortByTransactionDate() {
    // Convert linked list to a list for sorting
    List<TransactionNode> transactionsList = toList();
    transactionsList.sort((a, b) => a.transaction.date.compareTo(b.transaction.date));
    // Reconstruct the linked list with sorted elements
    clear();
    transactionsList.forEach((node) => add(node));
  }

  // Method to clear sorting and restore original order
  void clearSorting() {
    // No need to sort, as linked list maintains original order
  }
}
