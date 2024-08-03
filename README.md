# TransactionApp

**TransactionApp** is a Flutter application for managing and visualizing transactions. Users can add, delete, and sort transactions. The application also calculates the total amount spent and saves transactions locally using SharedPreferences.

## Table of Contents

- [Features](#features)
- [Technologies Used](#technologies-used)
- [Installation](#installation)
- [Usage](#usage)
- [Code Explanation](#code-explanation)
- [License](#license)

## Features

- Add new transactions with name, amount, and date.
- View and delete transactions.
- Sort transactions by name, amount, or date.
- Display total amount spent.

## Technologies Used

- **Flutter**: Framework for building the app.
- **SharedPreferences**: For storing transactions locally.
- **intl**: For formatting dates and currency.

## Setup and Installation

1. **Clone the Repository**

    ```sh
    git clone https://github.com/RishiMaddi1/Pave_ai_assignment.git
    ```

2. **Navigate to the Project Directory**

    ```sh
    cd Pave_ai_assignment
    ```

3. **Install Dependencies**

    ```sh
    flutter pub get
    ```

4. **Run the Application**

    ```sh
    flutter run
    ```

1. **Main Entry Point**

```sh
void main() {
  runApp(MaterialApp(
    home: TransactionApp(),
  ));
}
```
main(): This is the entry point of the Flutter application.
runApp(): It initializes the app and takes a Widget as an argument.
MaterialApp: Provides material design styling for the app. The home property sets the root widget of the application.
TransactionApp: The main widget of the application, which manages the transactions.

3. **TransactionApp Widget**

```sh
class TransactionApp extends StatefulWidget {
  @override
  _TransactionAppState createState() => _TransactionAppState();
}
```
TransactionApp: A StatefulWidget that has mutable state. It represents the main screen of the app.
createState(): Creates the mutable state for this widget, represented by _TransactionAppState.
4. **_TransactionAppState**

```
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
```
_TransactionAppState: Manages the mutable state for the TransactionApp widget.
SharedPreferences: Used to store and retrieve transaction data locally.
_transactions: A custom TransactionLinkedList that holds the list of transactions.
_sortBy: Indicates the current sorting criterion for transactions.
initState(): Called when the widget is inserted into the widget tree. Initializes SharedPreferences.
_initSharedPreferences(): Asynchronously initializes SharedPreferences and loads existing transactions.
_loadTransactions(): Loads transactions from SharedPreferences and updates the state.
_saveTransactions(): Saves transactions to SharedPreferences.
build(): Constructs the widget tree for the app.

4. **_bt Widget**

```sh
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
    separatorBuilder: (context, index) => Divider(height: 0),
    itemBuilder: (BuildContext context, int index) {
      final transaction = sortedTransactions[index].transaction;
      final formattedDate = DateFormat('MMM d, yyyy').format(transaction.date);

      return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
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
                    style: TextStyle(fontSize: 30, color: Colors.deepPurple, fontFamily: 'PoetsenOne'),
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
              SizedBox(width: 5),
              Text(
                '${transaction.amount}',
                style: TextStyle(
                    fontFamily: 'PoetsenOne',
                    fontSize: 30,
                    color: Colors.deepPurple
                ),
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
```
_bt(): Builds a list of transactions.
sortedTransactions: A list of transactions sorted based on the selected criterion.
ListView.separated: Creates a scrollable list with separators.
Container: Wraps each transaction with styling.
ListTile: Displays each transaction's name, date, and amount.

5.** _btas Widget**

```sh
Widget _btas() {
  double totalAmount = _ctotalAmt();
  String formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '\₹').format(totalAmount);
  return Container(
    height: MediaQuery.of(context).size.height * 0.3,
    alignment: Alignment.center,
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Text(
      'Amount Spent:\n$formattedAmount',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'PoetsenOne'),
    ),
  );
}
```
_btas(): Displays the total amount spent.
totalAmount: Calculates the total amount from all transactions.
formattedAmount: Formats the total amount as currency.
Container: Styles the container for the total amount.

6. **_displayDialog Method**

```sh
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
              maxLength: 12,
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
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              child: Text(
                DateFormat('MMM d, yyyy').format(selectedDate),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (name.isNotEmpty && amount > 0) {
                final transaction = Transaction(name: name, amount: amount, date: selectedDate);
                setState(() {
                  _transactions.add(TransactionNode(transaction));
                  _saveTransactions();
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
```
_displayDialog(): Shows a dialog to add a new transaction.
name, amount, selectedDate: Variables to hold the input values.
showDialog(): Displays the dialog with form fields for name, amount, and date.
TextField: For entering transaction details.
showDatePicker(): Allows the user to pick a date.
Navigator.of(context).pop(): Closes the dialog.
setState(): Updates the state to reflect the new transaction.

7. **_dtn Method**

```sh
void _dtn(TransactionNode node) {
  setState(() {
    _transactions.remove(node);
    _saveTransactions();
  });
}
```
_dtn(): Deletes a transaction.
_transactions.remove(): Removes the transaction from the list.
_saveTransactions(): Saves the updated list to SharedPreferences.

8. **_ctotalAmt Method**

```sh
double _ctotalAmt() {
  return _transactions.fold(0.0, (sum, node) => sum + node.transaction.amount);
}
```
_ctotalAmt(): Calculates the total amount of all transactions.
_transactions.fold(): Sums up the amounts from all transactions.

9. **_sso Method**

```sh
void _sso(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Name'),
              onTap: () {
                setState(() {
                  _sortBy = SortBy.name;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Amount'),
              onTap: () {
                setState(() {
                  _sortBy = SortBy.amount;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Date'),
              onTap: () {
                setState(() {
                  _sortBy = SortBy.date;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('None'),
              onTap: () {
                setState(() {
                  _sortBy = SortBy.none;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
```
_sso(): Shows a dialog for selecting sorting options.
ListTile: Displays sorting options (Name, Amount, Date, None).
setState(): Updates the sorting criterion.
    
