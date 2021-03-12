import 'package:flutter/material.dart';

typedef InteractionBuilder<I extends Interaction> = Iterable<Widget> Function(List<I> interaction, Rect rect);

abstract class InteractionSpec {}

abstract class InteractionResponse {
  final Interaction interaction;
  InteractionResponse(
    this.interaction,
  ) ;

  Offset? get offset => interaction.offset;
}

abstract class Interaction {
  final Offset? offset;
  Interaction(
    this.offset,
  );

  bool get isTapInteraction => this is TapInteraction;
  bool get isLongPressInteraction => this is LongPressInteraction;
  bool get isPointerInteraction => this is PointerInteraction;
  bool get hasEnded => this is PointerEndInteraction;
}

abstract class PointerInteraction extends Interaction {
  PointerInteraction(Offset? offset) : super(offset);
}

class PointerDownInteraction extends PointerInteraction {
  PointerDownInteraction(DragDownDetails details) : super(details.localPosition);
}

class PointerMoveInteraction extends PointerInteraction {
  PointerMoveInteraction(DragUpdateDetails details) : super(details.localPosition);
}

class PointerEndInteraction extends PointerInteraction {
  PointerEndInteraction() : super(null);
}

class TapInteraction extends Interaction {
  TapInteraction(Interaction interaction) : super(interaction.offset);
}

class LongPressInteraction extends Interaction {
  LongPressInteraction(Interaction interaction) : super(interaction.offset);
}
