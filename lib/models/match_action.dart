import 'package:snooke_master/widgets/score_board.dart';


enum ActionType {
  increase,
  decrease,
  nextFrame,
  reverseFrame,
  empty
}

abstract class BaseAction {
  ActionType actionType = ActionType.empty;

  // BaseAction({
  //   required this.actionType
  // });

  ActionType getReverseType() {
    switch (actionType) {
      case ActionType.increase: {
        return ActionType.decrease;
      }
      case ActionType.nextFrame: {
        return ActionType.reverseFrame;
      }
      default: {
        return ActionType.empty;
      }
    }
  }

  getReverseAction();

  void perform();

}

