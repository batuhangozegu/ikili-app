import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikili_app/core/theme/app_theme.dart';

class RoomCodeController extends ChangeNotifier {
  RoomCodeController({String initialCode = ''}) : _code = initialCode;

  String _code;
  String get code => _code;

  set code(String value) {
    if (_code == value) return;
    _code = value;
    notifyListeners();
  }

  void clear() => code = '';
}

class RoomCodeInput extends StatefulWidget {
  const RoomCodeInput({
    super.key,
    this.length = 4,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
  });

  final int length;
  final RoomCodeController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  late final RoomCodeController _controller;
  late final bool _ownsController;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RoomCodeController();
    _textController = TextEditingController(text: _controller.code);
    _focusNode = FocusNode();
    _controller.addListener(_syncFromController);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFromController);
    if (_ownsController) _controller.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncFromController() {
    if (_textController.text != _controller.code) {
      _textController.value = TextEditingValue(
        text: _controller.code,
        selection: TextSelection.collapsed(offset: _controller.code.length),
      );
    }
  }

  void _handleChanged(String value) {
    _controller.code = value;
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: Listenable.merge([_focusNode, _textController]),
        builder: (context, _) {
          final text = _textController.text;
          return Stack(
            fit: StackFit.expand,
            children: [
              Row(
                children: [
                  for (var i = 0; i < widget.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _DigitBox(
                        char: i < text.length ? text[i] : '',
                        isActive: _focusNode.hasFocus && i == text.length,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ],
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _focusNode.requestFocus();
                    _textController.selection = TextSelection.collapsed(
                      offset: _textController.text.length,
                    );
                  },
                  child: Opacity(
                    opacity: 0,
                    child: IgnorePointer(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus,
                        showCursor: false,
                        enableInteractiveSelection: false,
                        keyboardType: TextInputType.number,
                        maxLength: widget.length,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: _handleChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.char,
    required this.isActive,
    required this.colorScheme,
  });

  final String char;
  final bool isActive;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.accent
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
