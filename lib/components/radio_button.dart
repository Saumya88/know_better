import 'package:flutter/material.dart';

class RadioButton<String> extends StatelessWidget {
  final String value;
  final String groupValue;
  final String text;
  final Color squareColor;
  final String theory;
  final Function(String?) onChanged;

  const RadioButton({
    required this.value,
    required this.groupValue,
    required this.text,
    required this.squareColor,
    required this.theory,
    required this.onChanged,
  });

  Widget _buildText() {
    return Text(
      text.toString(),
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold,),
    );
  }

  Widget _buildSquare() {
    return Container(
      margin: const EdgeInsets.only(right: 3),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: squareColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
    );
  }

  Widget _buildTheory() {
    return Text(
      theory.toString(),
      style: const TextStyle(color: Colors.black, fontSize: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 2, 5, 0),
      child: InkWell(
        onTap: () {
          onChanged(value);
        },
        splashColor: Colors.cyan.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              const SizedBox(width: 20),
              _buildSquare(),
              const SizedBox(width: 3),
              Expanded(
                child: _buildText(),
              ),
              Expanded(
                flex: 2,
                child: _buildTheory(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
