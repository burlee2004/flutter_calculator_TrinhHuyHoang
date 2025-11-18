import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calculator",
      theme: ThemeData(fontFamily: "Roboto"),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = "0"; // hiển thị kết quả/số đang nhập
  String _expression = ""; // lưu toàn bộ biểu thức đầy đủ
  List<String> _history = []; // lịch sử tính toán
  final int _maxDigits = 15;

  /// ==========================
  /// HÀM THÊM SỐ VÀO DISPLAY
  /// ==========================
  void _onNumberTap(String n) {
    setState(() {
      if (_display == "0") {
        _display = n;
      } else {
        // không cho vượt quá số chữ số
        if (_display.replaceAll(".", "").replaceAll("-", "").length <
            _maxDigits) {
          _display += n;
        }
      }
    });
  }

  /// ==========================
  /// HÀM THÊM DẤU CHẤM
  /// ==========================
  void _onDecimal() {
    setState(() {
      if (!_display.contains(".")) {
        _display += ".";
      }
    });
  }

  /// ==========================
  /// HÀM XÓA TẤT CẢ
  /// ==========================
  void _onClear() {
    setState(() {
      _display = "0";
      _expression = "";
    });
  }

  /// ==========================
  /// XÓA TỪNG KÝ TỰ
  /// ==========================
  void _onBackspace() {
    setState(() {
      if (_display.length <= 1) {
        _display = "0";
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  /// ==========================
  /// ĐỔI DẤU +/-
  /// ==========================
  void _onToggleSign() {
    setState(() {
      if (_display.startsWith("-")) {
        _display = _display.substring(1);
      } else if (_display != "0") {
        _display = "-$_display";
      }
    });
  }

  /// ==========================
  /// PHẦN TRĂM
  /// ==========================
  void _onPercent() {
    setState(() {
      double v = double.tryParse(_display) ?? 0;
      v = v / 100.0;
      _display = _format(v);
    });
  }

  /// ==========================
  /// BẤM PHÉP TOÁN → GHÉP VÀO BIỂU THỨC
  /// ==========================
  void _onOperationTap(String op) {
    setState(() {
      // thêm số vừa nhập vào expression
      if (_expression.isEmpty) {
        _expression = _display;
      } else {
        _expression += " $_display";
      }

      // thêm toán tử vào expression
      _expression += " $op";

      // reset display để nhập số tiếp theo
      _display = "0";
    });
  }

  /// ==========================
  /// BẤM DẤU "="
  /// ==========================
  void _onEquals() {
    setState(() {
      if (_expression.isEmpty) return;

      // hoàn tất expression
      String expr = "$_expression $_display";

      double? result = _evaluateExpression(expr);

      if (result == null) {
        _display = "Error";
      } else {
        _history.add("$expr = ${_format(result)}"); // lưu lịch sử
        _display = _format(result);
      }

      _expression = "";
    });
  }

  /// ==========================
  /// FORMAT HIỂN THỊ
  /// ==========================
  String _format(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString();
    }
    String s = v.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r"0+$"), "");
    s = s.replaceAll(RegExp(r"\.$"), "");
    return s;
  }

  /// ==========================
  /// TOKENIZER — TÁCH CHUỖI THÀNH TOKEN
  /// ==========================
  List<String> _tokenize(String expr) {
    return expr.split(" ");
  }

  /// ==========================
  /// TÍNH TOÁN CÓ ƯU TIÊN × ÷ TRƯỚC
  /// ==========================
  double? _evaluateExpression(String expr) {
    try {
      List<String> tokens = _tokenize(expr);

      // bước 1: xử lý × và ÷ trước
      List<String> stack = [];
      for (int i = 0; i < tokens.length; i++) {
        String t = tokens[i];

        if (t == "×" || t == "÷") {
          double left = double.parse(stack.removeLast());
          double right = double.parse(tokens[++i]);

          double result = (t == "×")
              ? left * right
              : (right == 0 ? throw Exception("Div0") : left / right);

          stack.add(result.toString());
        } else {
          stack.add(t);
        }
      }

      // bước 2: xử lý + và -
      double total = double.parse(stack[0]);
      for (int i = 1; i < stack.length; i += 2) {
        String op = stack[i];
        double num = double.parse(stack[i + 1]);

        if (op == "+") total += num;
        if (op == "-") total -= num;
      }

      return total;
    } catch (_) {
      return null;
    }
  }

  /// ==========================
  /// UI BUTTON
  /// ==========================
  Widget _btn(String text, {Color? color, VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blueGrey,
            padding: const EdgeInsets.all(18),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// ==========================
  /// UI GIAO DIỆN
  /// ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Column(
                  children: [
                    // nút xóa lịch sử
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _history.clear();
                          });
                          Navigator.pop(context); // đóng bottom sheet
                        },
                        child: const Text(
                          "XÓA LỊCH SỬ",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    ),

                    const Divider(),

                    Expanded(
                      child: ListView(
                        children: _history
                            .map(
                              (h) => ListTile(
                                title: Text(
                                  h,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị biểu thức
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(16),
            child: Text(
              _expression,
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
          ),

          // Hiển thị số
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 45, color: Colors.white),
              ),
            ),
          ),

          // hàng nút bấm
          // hàng nút bấm
          Column(
            children: [
              Row(
                children: [
                  _btn("C", color: const Color(0xFF993333), onTap: _onClear),
                  _btn("CE", onTap: _onBackspace),
                  _btn("%", onTap: _onPercent),
                  _btn(
                    "÷",
                    color: const Color(0xFF339999),
                    onTap: () => _onOperationTap("÷"),
                  ),
                ],
              ),
              Row(
                children: [
                  _btn("7", onTap: () => _onNumberTap("7")),
                  _btn("8", onTap: () => _onNumberTap("8")),
                  _btn("9", onTap: () => _onNumberTap("9")),
                  _btn(
                    "×",
                    color: const Color(0xFF339999),
                    onTap: () => _onOperationTap("×"),
                  ),
                ],
              ),
              Row(
                children: [
                  _btn("4", onTap: () => _onNumberTap("4")),
                  _btn("5", onTap: () => _onNumberTap("5")),
                  _btn("6", onTap: () => _onNumberTap("6")),
                  _btn(
                    "-",
                    color: const Color(0xFF339999),
                    onTap: () => _onOperationTap("-"),
                  ),
                ],
              ),
              Row(
                children: [
                  _btn("1", onTap: () => _onNumberTap("1")),
                  _btn("2", onTap: () => _onNumberTap("2")),
                  _btn("3", onTap: () => _onNumberTap("3")),
                  _btn(
                    "+",
                    color: const Color(0xFF339999),
                    onTap: () => _onOperationTap("+"),
                  ),
                ],
              ),
              Row(
                children: [
                  _btn("±", onTap: _onToggleSign),
                  _btn("0", onTap: () => _onNumberTap("0")),
                  _btn(".", onTap: _onDecimal),
                  _btn("=", color: const Color(0xFF009966), onTap: _onEquals),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
