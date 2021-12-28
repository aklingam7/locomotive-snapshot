import "dart:math";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_material_color_picker/flutter_material_color_picker.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:infinite_listview/infinite_listview.dart";
import "package:locomotive/core/services/user_config_service.dart";
import "package:locomotive/core/widgets/alert_dialog.dart";
import "package:locomotive/core/widgets/text_field.dart";
import "package:locomotive/features/main_app/domain/entities/app_data.dart";
import "package:locomotive/features/main_app/domain/entities/coordinate.dart";
import "package:locomotive/features/main_app/domain/entities/date.dart";
import "package:locomotive/features/main_app/domain/entities/freight_car.dart";
import "package:locomotive/features/main_app/domain/entities/train.dart";
import "package:locomotive/features/main_app/domain/entities/user_profile.dart";
import "package:locomotive/features/main_app/presentation/bloc/main_app_bloc.dart";
import "package:locomotive/features/main_app/presentation/pages/settings_screen.dart";
import "package:locomotive/services.dart";
import "package:provider/provider.dart";

class MainApp extends StatefulWidget {
  const MainApp({required this.goToSignInPage, Key? key}) : super(key: key);

  final void Function() goToSignInPage;

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _mainAppBloc = MainAppBloc(
    uGetAppData: sl(),
    uUpdateLocalData: sl(),
    uSyncData: sl(),
    uGetUserProfile: sl(),
    uSignOut: sl(),
    uDeleteappData: sl(),
  );

  DateTime _lastSynced = DateTime.now();

  @override
  void initState() {
    Future.delayed(
      const Duration(milliseconds: 50),
      () => _mainAppBloc.add(LoadAppDataE()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<void Function()>(
      create: (_) => widget.goToSignInPage,
      builder: (context, _) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              HorizontalScrollView(
                bloc: _mainAppBloc,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: SizedBox(
                      height: 114,
                      width: 50,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            child: const Icon(Icons.sync),
                            onPressed: () {
                              if (DateTime.now()
                                      .difference(_lastSynced)
                                      .inSeconds >
                                  5) {
                                _mainAppBloc.add(SyncAppDataE());
                                _lastSynced = DateTime.now();
                              }
                            },
                          ),
                          Expanded(child: Container()),
                          FloatingActionButton(
                            child: const Icon(Icons.settings),
                            onPressed: () => _mainAppBloc.add(OpenSettingsE()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HorizontalScrollView extends StatelessWidget {
  const HorizontalScrollView({required this.bloc, Key? key}) : super(key: key);

  final MainAppBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TrainTracks(bloc: bloc),
            ),
          ),
        )
      ],
    );
  }
}

class TrainTracks extends StatefulWidget {
  const TrainTracks({
    required this.bloc,
    Key? key,
  }) : super(key: key);

  final MainAppBloc bloc;

  @override
  State<TrainTracks> createState() => _TrainTracksState();
}

class _TrainTracksState extends State<TrainTracks> {
  static const carHeight = 160.0;
  static const carWidth = 110.0;
  static const carMargin = 22.0;
  final double hoursPerCoal = sl<UserConfigService>().hoursPerCoal;

  AppData? _appData;
  late AppData? Function() getAppData;
  bool scrollPositionInitialized = false;
  Date todayDate = Date.today();

  @override
  void initState() {
    getAppData = () => _appData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppData? Function()>(
      create: (_) => getAppData,
      child: BlocConsumer(
        bloc: widget.bloc,
        listener: (context, state) {
          if (state is ErrorS) {
            showError(context);
          } else if (state is UpdateAppDataS) {
            if (state.appData.isValid) {
              final data = state.appData;
              if (_appData == null && data.source == AppDataSource.local) {
                showConnectToInternetMessage(context);
              }
              _appData = data;
            } else {
              _appData = null;
            }
          } else if (state is OpenSettingsS) {
            showSettingsDialog(context, widget.bloc, state.userProfile);
          } else if (state is GoToLoginS) {
            Provider.of<void Function()>(context, listen: false)();
          }
        },
        builder: (context, state) {
          return AbsorbPointer(
            absorbing: state is LoadingS,
            child: SizedBox(
              width: (carWidth + carMargin) * 16 + 200,
              child: _appData != null
                  ? InfiniteListView.builder(
                      reverse: true,
                      itemBuilder: (context, index) {
                        index = index + todayDate.day;
                        int totalCoal = 0;
                        for (final tr in TrainTrack.values) {
                          totalCoal += _appData!
                                  .carsMap[Coordinate(Date(index), tr)]
                                  ?.coalContent ??
                              0;
                        }
                        return Row(
                          children: [
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.A),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.A)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.A)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.B),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.B)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.B)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.C),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.C)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.C)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.D),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.D)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.D)],
                            ),
                            Expanded(
                              child: DateSign(
                                Date(index),
                                totalCoal: totalCoal,
                                hoursPerCoal: hoursPerCoal,
                              ),
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.E),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.E)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.E)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.F),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.F)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.F)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.G),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.G)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.G)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.H),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.H)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.H)],
                            ),
                            Expanded(
                              child: DateSign(
                                Date(index),
                                totalCoal: totalCoal,
                                hoursPerCoal: hoursPerCoal,
                              ),
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.I),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.I)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.I)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.J),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.J)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.J)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.K),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.K)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.K)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.L),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.L)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.L)],
                            ),
                            Expanded(
                              child: DateSign(
                                Date(index),
                                totalCoal: totalCoal,
                                hoursPerCoal: hoursPerCoal,
                              ),
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.M),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.M)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.M)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.N),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.N)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.N)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.O),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.O)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.O)],
                            ),
                            TrainCar(
                              bloc: widget.bloc,
                              height: carHeight,
                              width: carWidth,
                              margin: carMargin,
                              coordinate: Coordinate(Date(index), TrainTrack.P),
                              train: _appData!.trainsMap[
                                  Coordinate(Date(index), TrainTrack.P)],
                              freightCar: _appData!.carsMap[
                                  Coordinate(Date(index), TrainTrack.P)],
                            ),
                          ],
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}

class TrainCar extends StatelessWidget {
  const TrainCar({
    required this.height,
    required this.width,
    required this.margin,
    required this.train,
    required this.bloc,
    required this.coordinate,
    this.freightCar,
    Key? key,
  }) : super(key: key);
  final double height;
  final double width;
  final double margin;
  final Train? train;
  final FreightCar? freightCar;
  final MainAppBloc bloc;
  final Coordinate coordinate;

  static const double couplerHeight = 18;
  static const int railDistFactor = 4;

  Color textColor(int amt) {
    final color = Colors.blueGrey[900]!;
    return color.withAlpha(min(180 + amt * 4, 245));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: margin / 2),
      child: SizedBox(
        width: width,
        child: train != null
            ? train!.locomotivePosition == coordinate
                ? GestureDetector(
                    onTap: () => showTrainDialog(
                      context: context,
                      train: train!,
                      bloc: bloc,
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: height,
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: train!.color.getColor()[400],
                                      border: Border.all(
                                        color: train!.color.getColor()[400]!,
                                        width: width / 10,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(width / 10),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: train!.color.getColor()[400],
                                      border: Border.all(
                                        color: train!.color.getColor()[400]!,
                                        width: width / 10,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(width / 10),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: train!.color.getColor()[400],
                                      border: Border.all(
                                        color: train!.color.getColor()[400]!,
                                        width: width / 10,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(width / 10),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: train!.color.getColor()[200],
                                    border: Border.all(
                                      color: train!.color.getColor()[400]!,
                                      width: width / 8,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(width / 10),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: train!.color.getColor()[400],
                                      border: Border.all(
                                        color: train!.color.getColor()[400]!,
                                        width: width / 10,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(width / 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height,
                          width: width,
                          child: Center(
                            child: Opacity(
                              opacity: 0.3,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 24.0,
                                    right: 16.0,
                                  ),
                                  child: Card(
                                    elevation: 5,
                                    child: Text(
                                      train!.trainName,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: couplerHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                VerticalDivider(
                                  color: Colors.brown[700]!.withAlpha(100),
                                ),
                                const Expanded(
                                  flex: railDistFactor,
                                  child: SizedBox(),
                                ),
                                VerticalDivider(
                                  color: Colors.brown[700]!.withAlpha(100),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              thickness: couplerHeight / 2,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showCarDialog(
                          context: context,
                          train: train!,
                          car: freightCar ?? FreightCar(coordinate, 0),
                          bloc: bloc,
                        ),
                        child: Stack(
                          children: [
                            if (train!.caboosePosition == coordinate)
                              SizedBox(
                                height: height - couplerHeight,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: train!.color.getColor()[200],
                                          border: Border.all(
                                            color:
                                                train!.color.getColor()[400]!,
                                            width: width / 8,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(width / 10),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: train!.color.getColor()[200],
                                            border: Border.all(
                                              color:
                                                  train!.color.getColor()[400]!,
                                              width: width / 8,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              width / 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            else
                              Container(
                                height: height - couplerHeight,
                                decoration: BoxDecoration(
                                  color: train!.color.getColor()[100],
                                  border: Border.all(
                                    color: train!.color.getColor()[300]!,
                                    width: width / 10,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(width / 10),
                                ),
                              ),
                            if (freightCar != null)
                              Positioned(
                                top: train!.caboosePosition != coordinate
                                    ? 25
                                    : 7,
                                bottom: train!.caboosePosition != coordinate
                                    ? 25
                                    : 43,
                                left: 25,
                                right: 25,
                                child: SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: Center(
                                    child: Opacity(
                                      opacity: min(
                                            freightCar!.coalContent * 0.06,
                                            0.70,
                                          ) +
                                          0.30,
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Card(
                                          elevation: min(
                                                freightCar!.coalContent * 0.6,
                                                7,
                                              ) +
                                              3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "${freightCar!.coalContent}🪨",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
            : EmptyTrainTrack(
                height: height,
                coordinate: coordinate,
                bloc: bloc,
              ),
      ),
    );
  }
}

class EmptyTrainTrack extends StatefulWidget {
  const EmptyTrainTrack({
    Key? key,
    required this.height,
    required this.coordinate,
    required this.bloc,
  }) : super(key: key);

  final double height;
  final Coordinate coordinate;
  final MainAppBloc bloc;

  @override
  State<EmptyTrainTrack> createState() => _EmptyTrainTrackState();
}

class _EmptyTrainTrackState extends State<EmptyTrainTrack> {
  static const int railDistFactor = 4;

  bool _iconShown = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      flex: railDistFactor,
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.brown[700]!.withAlpha(100),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      flex: railDistFactor,
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.brown[700]!.withAlpha(100),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      flex: railDistFactor,
                      child: SizedBox(),
                    ),
                    VerticalDivider(
                      color: Colors.brown[700]!.withAlpha(100),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.brown[700]!.withAlpha(100),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: _iconShown ? 1 : 0.05,
          duration: const Duration(milliseconds: 500),
          child: Center(
            child: Card(
              elevation: 20,
              child: InkWell(
                onHover: (value) {
                  setState(() => _iconShown = true);
                  Future.delayed(
                    const Duration(seconds: 2),
                    () => setState(() => _iconShown = false),
                  );
                },
                child: IconButton(
                  onPressed: () {
                    if (!_iconShown) {
                      setState(() => _iconShown = true);
                      Future.delayed(
                        const Duration(seconds: 3),
                        () => setState(() => _iconShown = false),
                      );
                    } else {
                      showCreateTrainDialog(
                        context,
                        widget.bloc,
                        widget.coordinate,
                      );
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.plus),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DateSign extends StatelessWidget {
  const DateSign(
    this.date, {
    Key? key,
    required this.totalCoal,
    required this.hoursPerCoal,
  }) : super(key: key);

  final int totalCoal;
  final Date date;
  final double hoursPerCoal;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: Column(
            children: [
              Text(
                date.toDateTime().day.toString(),
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                shortMonths[date.toDateTime().month - 1],
                style: Theme.of(context).textTheme.bodyText1,
              ),
              if (totalCoal >= 1) ...[
                const Divider(),
                Text(
                  "$totalCoal🪨",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Divider(),
                Text(
                  "${(totalCoal * hoursPerCoal * 10).round() / 10} Hours",
                  textAlign: TextAlign.center,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

void showConnectToInternetMessage(BuildContext context) {
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (_) {
      return Provider.value(
        value: appData,
        builder: (context, _) => AlertDialogW(
          title: "Not Connected to the Internet:",
          body:
              "We recommend that you connect to the internet, especially if you use the app on more than one device to prevent conflicts while syncing.",
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

void showCreateTrainDialog(
  BuildContext context,
  MainAppBloc bloc,
  Coordinate caboosePosition,
) {
  String? _trainName;
  Coordinate? _locomotivePosition;
  TrainColor? _trainColor;
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (_) {
      return Provider.value(
        value: appData,
        builder: (context, _) => AlertDialogW(
          title: "Create Train",
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Scrollbar(
              interactive: true,
              isAlwaysShown: true,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFieldW(
                    label: const Text("Train Name"),
                    onChanged: (value) {
                      _trainName = value;
                    },
                    controller: TextEditingController(
                      text: _trainName,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "End Date:",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: ListWheelScrollView(
                                diameterRatio: 1.3,
                                itemExtent: 35,
                                onSelectedItemChanged: (value) =>
                                    _locomotivePosition = Coordinate(
                                  caboosePosition.date + value + 1,
                                  caboosePosition.track,
                                ),
                                children: [
                                  for (int i = 1; i <= 300; i++)
                                    Container(
                                      padding: const EdgeInsets.all(
                                        4,
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Text(
                                          "${(caboosePosition.date + i).toDateTime().day} ${shortMonths[(caboosePosition.date + i).toDateTime().month - 1]}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    "Train Color:",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  MaterialColorPicker(
                    allowShades: false,
                    onMainColorChange: (color) {
                      if (color != null) _trainColor = color.getTrainColor();
                    },
                    selectedColor: Colors.green,
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Create"),
              onPressed: () {
                if (_trainName != null &&
                    _locomotivePosition != null &&
                    _trainColor != null) {
                  bloc.add(
                    CreateTrainE(
                      Train(
                        trainName: _trainName!,
                        color: _trainColor!,
                        caboosePosition: caboosePosition,
                        locomotivePosition: _locomotivePosition!,
                      ),
                      Provider.of<AppData? Function()>(
                        context,
                        listen: false,
                      )(),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialogW(
                        title: "Error",
                        body: "Please fill out all fields.",
                        actions: [
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

void showTrainDialog({
  required BuildContext context,
  required Train train,
  required MainAppBloc bloc,
}) {
  String trainName = train.trainName;
  TrainColor trainColor = train.color;
  Date locomotiveDate = train.locomotivePosition.date;
  Date cabooseDate = train.caboosePosition.date;
  int totalCoal = 0;
  for (Date date = cabooseDate; date.day <= locomotiveDate.day; date++) {
    totalCoal += Provider.of<AppData? Function()>(context, listen: false)()
            ?.carsMap[Coordinate(date, train.locomotivePosition.track)]
            ?.coalContent ??
        0;
  }
  var dateRangeValues = RangeValues(
    30,
    train.locomotivePosition.date.day - train.caboosePosition.date.day + 30,
  );
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      return Provider.value(
        value: appData,
        builder: (context, _) => AlertDialogW(
          title: "Train Details",
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Scrollbar(
              interactive: true,
              isAlwaysShown: true,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFieldW(
                          label: const Text("Train Name"),
                          value: trainName,
                          onChanged: (value) {
                            trainName = value;
                          },
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              "Total Coal Carried:",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const Divider(),
                            Text(
                              "$totalCoal🪨",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              "Total Time Spent:",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const Divider(),
                            Text(
                              "${totalCoal * sl<UserConfigService>().hoursPerCoal} Hrs.",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    "Change Dates:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return RangeSlider(
                        values: dateRangeValues,
                        max: 60.0 +
                            train.locomotivePosition.date.day -
                            train.caboosePosition.date.day,
                        divisions: 60 +
                            train.locomotivePosition.date.day -
                            train.caboosePosition.date.day,
                        labels: RangeLabels(
                          "${cabooseDate.toDateTime().day} ${shortMonths[cabooseDate.toDateTime().month - 1]}",
                          "${locomotiveDate.toDateTime().day} ${shortMonths[locomotiveDate.toDateTime().month - 1]}",
                        ),
                        onChanged: (val) {
                          if (val.start != val.end) {
                            final offsetCD = val.start.round() - 30;
                            final offsetLD = val.end.round() -
                                (train.locomotivePosition.date.day -
                                    train.caboosePosition.date.day +
                                    30);
                            cabooseDate = train.caboosePosition.date + offsetCD;
                            locomotiveDate =
                                train.locomotivePosition.date + offsetLD;
                            setState(() {
                              dateRangeValues = val;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    "Change Color:",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  MaterialColorPicker(
                    allowShades: false,
                    onMainColorChange: (color) {
                      if (color != null) trainColor = color.getTrainColor();
                    },
                    selectedColor: Colors.green,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      child: const Text("Delete Train"),
                      onPressed: () {
                        bloc.add(
                          DeleteTrainE(
                            train,
                            Provider.of<AppData? Function()>(
                              context,
                              listen: false,
                            )(),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save Changes"),
              onPressed: () {
                final freightCars =
                    Provider.of<AppData? Function()>(context, listen: false)()!
                        .freightCars;
                freightCars.removeWhere(
                  (car) =>
                      ((car.position.date.day <=
                                  train.locomotivePosition.date.day &&
                              car.position.date.day >= locomotiveDate.day) ||
                          (car.position.date.day >=
                                  train.caboosePosition.date.day &&
                              car.position.date.day < cabooseDate.day)) &&
                      car.position.track == train.locomotivePosition.track,
                );
                final oldTrains =
                    Provider.of<AppData? Function()>(context, listen: false)()!
                        .trains;
                final newTrains = <Train>[];
                for (final tr in oldTrains) {
                  if (tr.trainName != train.trainName) {
                    newTrains.add(tr);
                  }
                }
                newTrains.add(
                  Train(
                    trainName: trainName,
                    color: trainColor,
                    locomotivePosition: Coordinate(
                      locomotiveDate,
                      train.locomotivePosition.track,
                    ),
                    caboosePosition: Coordinate(
                      cabooseDate,
                      train.caboosePosition.track,
                    ),
                  ),
                );
                bloc.add(
                  UpdateAppDataE(
                    AppData(
                      trains: newTrains,
                      freightCars: freightCars,
                      source: AppDataSource.local,
                    ),
                    Provider.of<AppData? Function()>(
                      context,
                      listen: false,
                    )()!,
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

void showCarDialog({
  required Train train,
  required FreightCar car,
  required MainAppBloc bloc,
  required BuildContext context,
}) {
  int coalCarried = car.coalContent;
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      return Provider.value(
        value: appData,
        builder: (context, _) => AlertDialogW(
          title: "Add Coal:",
          content: SizedBox(
            width: 200,
            height: 70,
            child: Scrollbar(
              interactive: true,
              isAlwaysShown: true,
              child: ListView(
                shrinkWrap: true,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              splashColor:
                                  Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                setState(
                                  () {
                                    if (coalCarried > 0) coalCarried--;
                                  },
                                );
                              },
                              icon: const FaIcon(FontAwesomeIcons.minus),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Card(
                              color: Theme.of(context).colorScheme.secondary,
                              elevation: 5,
                              child: Text(
                                "$coalCarried🪨",
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              splashColor:
                                  Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                setState(
                                  () {
                                    if (coalCarried < 99) coalCarried++;
                                  },
                                );
                              },
                              icon: const FaIcon(FontAwesomeIcons.plus),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                bloc.add(
                  AddCoalE(
                    coalCarried,
                    car.position,
                    Provider.of<AppData? Function()>(
                      context,
                      listen: false,
                    )(),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

void showSettingsDialog(
  BuildContext context,
  MainAppBloc bloc,
  UserProfile userProfile,
) {
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      return Provider.value(
        value: appData,
        builder: (context, _) => SettingsScreen(userProfile, bloc: bloc),
      );
    },
  );
}

void showError(
  BuildContext context, {
  String? title,
  String? body,
}) {
  title ??= AppLocalizations.of(context)!.defaultError_T;
  body ??= AppLocalizations.of(context)!.defaultErrorBody_ML;
  final appData = Provider.of<AppData? Function()>(context, listen: false);
  showDialog(
    context: context,
    builder: (_) => Provider.value(
      value: appData,
      builder: (context, _) => AlertDialogW(
        title: title!,
        body: body,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok_BL),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}

const shortMonths = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];
