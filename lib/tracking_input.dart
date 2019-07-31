import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'flare_controller.dart';

class TrackingInput extends StatefulWidget {
  @override
  TrackingState createState() => TrackingState();
}

class TrackingState extends State<TrackingInput> {
  ///these get set when we build the widget
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  ///let's set up all of the animation controllers
  AnimationControls _flareController;

  final FlareControls plusWaterControls = FlareControls();
  final FlareControls minusWaterControls = FlareControls();

  final FlareControls plusGoalControls = FlareControls();
  final FlareControls minusGoalControls = FlareControls();

  final FlareControls resetDayControls = FlareControls();

  ///the current number of glasses drunk
  int currentWaterCount = 0;

  ///this will come from the selectedGlasses times ouncesPerGlass
  /// we'll use this to calculate the transform of the water fill animation
  int maxWaterCount = 0;

  ///we'll default at 8, but this will change based on user input
  int selectedGlasses = 8;

  ///this doesn't change, hence the 'static const', we always count 8 ounces
  ///per glass (it's assuming)
  static const int ouncePerGlass = 8;

  @override
  void initState() {
    _flareController = AnimationControls();

    super.initState();
  }

  ///this is a quick reset for the user, to reset the intake back to zero
  void _resetDay() {
    setState(() {
      currentWaterCount = 0;
      _flareController.resetWater();
    });
  }

  ///we'll use this to increase how much water the user has drunk, hooked
  ///via button
  void _incrementWater() {
    setState(() {
      if (currentWaterCount < selectedGlasses) {
        currentWaterCount = currentWaterCount + 1;

        double diff = currentWaterCount / selectedGlasses;

        plusWaterControls.play("plus press");

        _flareController.playAnimation("ripple");

        _flareController.updateWaterPercent(diff);
      }

      if (currentWaterCount == selectedGlasses) {
        _flareController.playAnimation("iceboy_win");
      }
    });
  }

  ///we'll use this to decrease our user's water intake, hooked to a button
  void _decrementWater() {
    setState(() {
      if (currentWaterCount > 0) {
        currentWaterCount = currentWaterCount - 1;
        double diff = currentWaterCount / selectedGlasses;

        _flareController.updateWaterPercent(diff);

        _flareController.playAnimation("ripple");
      } else {
        currentWaterCount = 0;
      }
      minusWaterControls.play("minus press");
    });
  }

  ///user will push a button to increase how many glasses they want to
  ///drink per day
  void _incrementGoal(StateSetter updateModal) {
    updateModal(() {
      if (selectedGlasses <= 25) {
        selectedGlasses = selectedGlasses + 1;
        calculateMaxOunces();
        plusGoalControls.play("arrow right press");
      }
    });
  }

  ///users will push a button to decrease how many glasses they want to
  ///drink per day
  void _decrementGoal(StateSetter updateModal) {
    //setState(() {
    updateModal(() {
      if (selectedGlasses > 0) {
        selectedGlasses = selectedGlasses - 1;
      } else {
        selectedGlasses = 0;
      }
      calculateMaxOunces();
      minusGoalControls.play("arrow left press");
    });
  }

  void calculateMaxOunces() {
    maxWaterCount = selectedGlasses * ouncePerGlass;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(93, 93, 93, 1),
      body: Container(
        //Stack some widgets
        color: const Color.fromRGBO(93, 93, 93, 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlareActor(
              "assets/WaterArtboards.flr",
              controller: _flareController,
              fit: BoxFit.contain,
              animation: "iceboy",
              artboard: "Artboard",
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                // Might want to consider changing these to individual widgets
                addWaterBtn(),
                subWaterBtn(),
                settingsButton(),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _incSelectedGlasses(StateSetter updateModal, int value) {
    updateModal(() {
      selectedGlasses = (selectedGlasses + value).clamp(0, 26).toInt();
      calculateMaxOunces();
    });
  }

  ///set up our bottom sheet menu
  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter updateModal) {
            return Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(93, 93, 93, 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Set Target",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FlareWaterTrackButton(
                        artboard: "UI arrow left",
                        pressAnimation: "arrow left press",
                        onPressed: () => _incSelectedGlasses(updateModal, -1),
                      ),
                      Expanded(
                        child: Text(
                          selectedGlasses.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 40.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FlareWaterTrackButton(
                        artboard: "UI arrow right",
                        pressAnimation: "arrow right press",
                        onPressed: () => _incSelectedGlasses(updateModal, 1),
                      ),
                    ],
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  Text(
                    "/glasses",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  // Some vertical padding between text and buttons row
                  const SizedBox(height: 20),
                  FlareWaterTrackButton(
                    artboard: "UI refresh",
                    onPressed: () {
                      _resetDay();
                      // close modal
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget settingsButton() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(Size(95, 30)),
      onPressed: _showMenu,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          fit: BoxFit.contain, sizeFromArtboard: true, artboard: "UI Ellipse"),
    );
  }

  Widget addWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _incrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: plusWaterControls,
          fit: BoxFit.contain,
          animation: "plus press",
          sizeFromArtboard: false,
          artboard: "UI plus"),
    );
  }

  Widget subWaterBtn() {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(150, 150)),
      onPressed: _decrementWater,
      shape: Border(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0.0,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: minusWaterControls,
          fit: BoxFit.contain,
          animation: "minus press",
          sizeFromArtboard: true,
          artboard: "UI minus"),
    );
  }

  Widget increaseGoalBtn(StateSetter updateModal) {
    return Positioned(
      left: screenWidth * .7,
      top: screenHeight * .1,
      child: RawMaterialButton(
        constraints: BoxConstraints.tight(const Size(95, 85)),
        onPressed: () => _incrementGoal(updateModal),
        shape: Border(),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        elevation: 0.0,
        child: FlareActor("assets/WaterArtboards.flr",
            controller: plusGoalControls,
            fit: BoxFit.contain,
            animation: "arrow right press",
            sizeFromArtboard: true,
            artboard: "UI arrow right"),
      ),
    );
  }

  Widget decreaseGoalBtn(StateSetter updateModal) {
    return Positioned(
      left: screenWidth * .1,
      top: screenHeight * .1,
      child: RawMaterialButton(
        constraints: BoxConstraints.tight(const Size(95, 85)),
        onPressed: () => _decrementGoal(updateModal),
        shape: Border(),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        elevation: 0.0,
        child: FlareActor("assets/WaterArtboards.flr",
            controller: minusGoalControls,
            fit: BoxFit.contain,
            animation: "arrow left press",
            sizeFromArtboard: true,
            artboard: "UI arrow left"),
      ),
    );
  }

  Widget resetProgressBtn() {
    return Positioned(
      left: screenWidth * .42,
      top: screenHeight * .30,
      child: RawMaterialButton(
        constraints: BoxConstraints.tight(const Size(95, 85)),
        onPressed: _resetDay,
        shape: Border(),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        elevation: 0.0,
        child: FlareActor("assets/WaterArtboards.flr",
            controller: resetDayControls,
            fit: BoxFit.contain,
            animation: "Untitled",
            sizeFromArtboard: true,
            artboard: "UI refresh"),
      ),
    );
  }
}

/// Button with a Flare widget that automatically plays
/// a Flare animation when pressed. Specify which animation
/// via [pressAnimation] and the [artboard] it's in.
class FlareWaterTrackButton extends StatefulWidget {
  final String pressAnimation;
  final String artboard;
  final VoidCallback onPressed;
  const FlareWaterTrackButton(
      {this.artboard, this.pressAnimation, this.onPressed});

  @override
  _FlareWaterTrackButtonState createState() => _FlareWaterTrackButtonState();
}

class _FlareWaterTrackButtonState extends State<FlareWaterTrackButton> {
  final _controller = FlareControls();

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tight(const Size(95, 85)),
      onPressed: () {
        _controller.play(widget.pressAnimation);
        widget.onPressed?.call();
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: FlareActor("assets/WaterArtboards.flr",
          controller: _controller,
          fit: BoxFit.contain,
          artboard: widget.artboard),
    );
  }
}
