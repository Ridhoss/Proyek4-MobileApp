class CounterController {
  int _counter = 0;
  int step = 1;

  int get value => _counter;

  List<String> history = [];

  void _addHistory(String message) {
    history.insert(0, message);

    if (history.length > 5) {
      history.removeLast();
    }
  }

  void incStep() => step++;
  void decStep() {
    if (step > 1) step--;
  }

  void increment() {
    _counter += step;
    _addHistory("+$step");
  }

  void decrement() {
    if (_counter > 0) _counter -= step;
    _addHistory("-$step");
  }

  void reset() {
    _counter = 0;
    step = 1;
    _addHistory("-RESET-");
  }
}
