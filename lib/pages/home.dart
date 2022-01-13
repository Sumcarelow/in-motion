import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_motion/extras/address_search.dart';
import 'package:in_motion/extras/data.dart';
import 'package:in_motion/extras/places_pages.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'confirm.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Trip Information variables
  String pickUp, dropOff, _pickUpStreet, _dropOffStreet, _pickUpStreetNumber, _dropOffStreetNumber, _pickUpCity, _dropOffCity, rideType;
  double distance, baseFare = 22;
  List<DocumentSnapshot> requests = List<DocumentSnapshot>();
  String id, firstName, lastName, role, pic, currentRequest;
  SharedPreferences prefs;
  TextEditingController controllerPickUp = TextEditingController();
  TextEditingController controllerDropOff = TextEditingController();
  final FocusNode focusNodePickUp = FocusNode();
  final FocusNode focusNodeDropOff = FocusNode();

  //Google Maps Functions
   GoogleMapController mapController;
   LocationData _currentPosition;
   Location location = Location();
   LatLng sourcePos, destinationPos;
   LatLng _center = const LatLng(45.521563, -122.677433);
   BitmapDescriptor pinLocationIcon;
   Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};


// this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];


// this is the key object - the PolylinePoints
// which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = 'AIzaSyCHFW0zZvtKcmjBltp5QaRIMb-dEPcj2so';

  bool isLoading = false;
  bool isRequesting = false;

  //Read Local Data
  void readLocal() async{
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    lastName = prefs.getString('lastName') ?? '';
    role = prefs.getString('role') ?? '';
    pic = prefs.getString('pic') ?? '';
    setState(() {

    });
  }

  //Check if user is currently requesting
  void checkRequest() async {
    QuerySnapshot result =
    await Firestore.instance.collection('requests').where('userId', isEqualTo: id).getDocuments();
    List<DocumentSnapshot> myRequests = result.documents;
    myRequests.forEach((element) {
      if(element['status'] != 'pending'){
        setState(() {
          isRequesting = false;
        });
      } else {
        setState(() {
          currentRequest = element['id'];
          isRequesting = true;
        });
      }
    });
  }

  //Update list using category filter
  void updateRequests() async{
    setState(() {
      isLoading = true;
    });
    requests.clear();
    QuerySnapshot result =
    await Firestore.instance.collection('requests').where("status", isEqualTo: 'pending').getDocuments();
    setState(() {
      requests = result.documents;
    });
    setState(() {
      isLoading = false;
    });
  }

  //Book Ride
  void bookRide() async{
    setState(() {
      isLoading = true;
    });
    DocumentReference docRef = Firestore.instance.collection('requests').document();
    docRef.setData({
      'name': firstName + ' ' + lastName,
      'userId': id,
      'id': docRef.documentID,
      'pickUp': pickUp,
      'dropOff': dropOff,
      'rideType': rideType,
      'status': 'pending',
      'pickUpLocation': sourcePos,
      'dropOffLocation': destinationPos,
      'date': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString(),
      'time': DateFormat('hh:mm:ss').format(DateTime.now()).toString()
    }).then((data) async {
      setState(() {
        isRequesting = true;
        currentRequest = docRef.documentID;
      });
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    location.onLocationChanged.listen((l) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
        ),
      );
    });
  }

  void _onMapReload(GoogleMapController controller, LatLng newLocation) {
    mapController = controller;
    location.onLocationChanged.listen((l) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLocation,zoom: 15),
        ),
      );
    });
    controller.hideMarkerInfoWindow(MarkerId('myLocation'));
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        sourcePos.latitude,
        sourcePos.longitude,
        destinationPos.latitude,
        destinationPos.longitude);
    if(result.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point){
        polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          color: colors[2],
          points: polylineCoordinates
      );

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
    double distanceInMeters = await Geolocator().distanceBetween(
      sourcePos.latitude,
      sourcePos.longitude,
      destinationPos.latitude,
      destinationPos.longitude,
    );
    setState(() {
      distance = distanceInMeters/1000;
    });
  }

   getLoc() async {
     bool _serviceEnabled;
     PermissionStatus _permissionGranted;

     _serviceEnabled = await location.serviceEnabled();
     if (!_serviceEnabled) {
       _serviceEnabled = await location.requestService();
       if (!_serviceEnabled) {
         return;
       }
     }

     _permissionGranted = await location.hasPermission();
     if (_permissionGranted == PermissionStatus.denied) {
       _permissionGranted = await location.requestPermission();
       if (_permissionGranted != PermissionStatus.granted) {
         return;
       }
     }

     _currentPosition = await location.getLocation();
     _center = LatLng(_currentPosition.latitude,_currentPosition.longitude);
     location.onLocationChanged.listen((LocationData currentLocation) {
       print("${currentLocation.longitude} : ${currentLocation.longitude}");
       setState(() {
         _currentPosition = currentLocation;
         _center = LatLng(_currentPosition.latitude,_currentPosition.longitude);

       });
     });
   }

   Future<bool> onBackPress() {
    if(isRequesting){
      openRequestCancelDialog();
    } else {
      openDialog();
    }
     return Future.value(false);
   }

   Future<Null> openDialog() async {
     switch (await showDialog(
         context: context,
         builder: (BuildContext context) {
           return SimpleDialog(
             contentPadding:
             EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
             children: <Widget>[
               Container(
                 color: colors[0],
                 margin: EdgeInsets.all(0.0),
                 padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                 height: 100.0,
                 child: Column(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.exit_to_app,
                         size: 30.0,
                         color: colors[4],
                       ),
                       margin: EdgeInsets.only(bottom: 10.0),
                     ),
                     Text(
                       'Exit app',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 18, fontWeight: FontWeight.bold)),
                     ),
                     Text(
                       'Are you sure to exit app?',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 16,)),
                     ),
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   Navigator.pop(context, 0);
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.cancel,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'CANCEL',
                       style: GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   Navigator.pop(context, 1);
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.check_circle,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'YES',
                       style:  GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
             ],
           );
         })) {
       case 0:
         break;
       case 1:
         exit(0);
         break;
     }
   }

   //Open Request Response Dialog
   Future<Null> openRequestDialog() async {
     await showDialog(
         context: context,
         builder: (BuildContext context) {
           return SimpleDialog(
             contentPadding:
             EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
             children: <Widget>[
               Container(
                 color: colors[0],
                 margin: EdgeInsets.all(0.0),
                 padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                 height: 100.0,
                 child: Column(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.car_rental,
                         size: 30.0,
                         color: colors[4],
                       ),
                       margin: EdgeInsets.only(bottom: 10.0),
                     ),
                     Text(
                       'Request Response',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 18, fontWeight: FontWeight.bold)),
                     ),
                     Text(
                       'Would you like accept request?',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 16,)),
                     ),
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   Navigator.pop(context);
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.cancel,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'Decline',
                       style: GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   Navigator.pop(context);
                   acceptRequest();
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.check_circle,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'Accept',
                       style:  GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
             ],
           );
         });
   }


   //Open Cancel Request Dialog
   Future<Null> openRequestCancelDialog() async {
     await showDialog(
         context: context,
         builder: (BuildContext context) {
           return SimpleDialog(
             contentPadding:
             EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
             children: <Widget>[
               Container(
                 color: colors[0],
                 margin: EdgeInsets.all(0.0),
                 padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                 height: 100.0,
                 child: Column(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.car_rental,
                         size: 30.0,
                         color: colors[4],
                       ),
                       margin: EdgeInsets.only(bottom: 10.0),
                     ),
                     Text(
                       'Cancel Request',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 18, fontWeight: FontWeight.bold)),
                     ),
                     Text(
                       'Are sure you want to cancel request?',
                       style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 16,)),
                     ),
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   Navigator.pop(context);
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.cancel,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'No, continue searching',
                       style: GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
               SimpleDialogOption(
                 onPressed: () {
                   deleteRequest();
                   Navigator.pop(context);
                 },
                 child: Row(
                   children: <Widget>[
                     Container(
                       child: Icon(
                         Icons.check_circle,
                         color: colors[0],
                       ),
                       margin: EdgeInsets.only(right: 10.0),
                     ),
                     Text(
                       'Yes, cancel request',
                       style:  GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
               ),
             ],
           );
         });
   }

   //Delete Request Function
  void deleteRequest() {
    Firestore.instance.collection('requests').document(currentRequest).delete();
    checkRequest();
  }

  //Accept Request
  void acceptRequest() {
    Firestore.instance.collection('requests').document(currentRequest).updateData(
        {
          'status': 'accepted'
        });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Confirm()));
  }

  //Check if Driver has responded
  Widget checkResponse(){
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('requests').where("userId", isEqualTo: id).snapshots(),
        builder: (context, snapshot) {
          Widget myWidget;
          final data = snapshot.requireData;
          data.documents.forEach((element) {
            if(element['status'] == 'accepted'){
              setState(() {
                isRequesting = false;
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Confirm()));
              });
              myWidget =  Container();
            }
            else {
               myWidget  =  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: colors[3],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Looking for a driver...",
                        style: TextStyle(
                            color: colors[3]
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: colors[3],
                    child: Text("Cancel"),
                    onPressed: openRequestCancelDialog,
                  )
                ],
              );
            }
          });
          return myWidget;
        }
    );
  }
//Checkbox Options
  Row categoryLabel(String category) {
    return Row(
      children: [
        Radio(
          activeColor: colors[2],
          groupValue: rideType,
          value: category,
          onChanged: (String value){
            switch(rideType){
              case 'Hatch backs &sedans':
              setState(() {
                baseFare = 22.0;
              });
              break;
              case 'XL':
              setState(() {
                baseFare = 22.0;
              });
               break;
              case 'VAN':
                setState(() {
                  baseFare = 250.0;
                });
               break;
              case 'MINI TRUCK':
                setState(() {
                  baseFare = 250.0;
                });
            }
            setState(() {
              rideType = value;

            });
          },
        ),
        Text(category,
          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[0], fontSize: 12,)),
        ),
      ],
    );
  }

  //Rider Body
  Widget riderBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: colors[4],
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: colors[0]),
            child: TextFormField(
                onTap: () async {
                  // generate a new token here
                  final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      controllerPickUp.text = result.description;
                      _pickUpStreetNumber = placeDetails.streetNumber;
                      _pickUpStreet = placeDetails.street;
                      _pickUpCity = placeDetails.city;
                      pickUp = "$_pickUpStreetNumber" + " $_pickUpStreet" + " $_pickUpCity" ;
                    });
                    List<Placemark> placemark = await Geolocator().placemarkFromAddress(result.description);
                    LatLng pos = LatLng(placemark[0].position.latitude, placemark[0].position.longitude);
                    setState(() {
                      _polylines.clear();
                      sourcePos = pos;
                      _center = pos;
                      _markers.add(
                          Marker(
                              markerId: MarkerId('pickUp'),
                              position: pos,
                              icon: pinLocationIcon
                          )
                      );
                    });
                    _onMapReload(mapController, pos);
                    print(sourcePos);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Pick Up Location',
                  contentPadding: new EdgeInsets.all(5.0),
                  hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                controller: controllerPickUp,
                readOnly: true,
                focusNode: focusNodePickUp,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Cannot be empty';
                  }
                  return null;
                }
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),
        Container(
          color: colors[4],
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: colors[0]),
            child: TextFormField(
                onTap: () async {
                  // generate a new token here
                  final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      controllerDropOff.text = result.description;
                      _dropOffStreetNumber = placeDetails.streetNumber;
                      _dropOffStreet = placeDetails.street;
                      _dropOffCity = placeDetails.city;
                      dropOff = "$_dropOffStreetNumber" + " $_dropOffStreet" + " $_dropOffCity" ;
                    });
                    List<Placemark> placemark = await Geolocator().placemarkFromAddress(result.description);
                    LatLng pos = LatLng(placemark[0].position.latitude, placemark[0].position.longitude);
                    setState(() {
                      _polylines.clear();
                      destinationPos = pos;
                      _markers.add(
                          Marker(
                              markerId: MarkerId('dropOff'),
                              position: pos,
                              icon: pinLocationIcon
                          )
                      );
                    });
                    print(destinationPos);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Drop Off Location',
                  contentPadding: new EdgeInsets.all(5.0),
                  hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                controller: controllerDropOff,
                readOnly: true,
                focusNode: focusNodeDropOff,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Cannot be empty';
                  }
                  return null;
                }
            ),
          ),
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
        ),

        distance == null
        ? Container()
        //Ride Type Selector
        : Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Container(
            color: colors[4],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    categoryLabel("Hatch backs & sedans"),
                    categoryLabel("XL"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    categoryLabel("Van"),
                    categoryLabel("MINI TRUCK"),
                  ],
                ),
              ],
            ),
          ),
        ),
        //Price Displayer
        rideType == null
            ? Container()
            : Container(
          margin: EdgeInsets.only(left: 30.0, right: 30.0),
          color: colors[4],
          child: Center(
            child: Text("Total Price R${(distance* 7.5 + baseFare) .toStringAsFixed(2)}",
              style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[0], fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: RaisedButton(onPressed: (){
                if (sourcePos != null && destinationPos != null && _polylines.isEmpty){
                  setPolylines();
                }
                else if(distance != null && !isEmpty(rideType)){
                  bookRide();
                }
                else {
                  Fluttertoast.showToast(msg: "Please fill in destinations first");
                }
              },
                color: colors[0],
                child: _polylines != null && distance != null
                    ? Text('Request Now', style: TextStyle(color: colors[2]),)

                    : Text('Next', style: TextStyle(color: colors[2]),),
              ),
            )
          ],
        )
      ],
    );
  }

  //Driver Body
  Widget driverBody2(){
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index){
        var request;
        if (requests.isEmpty || requests.length == 0){

        }else{
          request = requests[index];
        }
        return Container(
          color: colors[0],
          child: ListTile(
            onTap: ()
        {
          setState(() {
            currentRequest = request['id'];
          });
          openRequestDialog();
        },
            leading: Icon(Icons.car_rental,
              color: colors[2],
              size: 34,
            ),
            title: Text("${request['name']} ",
              style: GoogleFonts.getFont('Noto Serif', textStyle: TextStyle(color: colors[2], fontSize: 18,)),
            ),
            subtitle: Text("PickUp: ${request['pickUp']}",
              style: GoogleFonts.getFont('Noto Serif', textStyle: TextStyle(color: colors[2], fontSize: 14,)),
            ),
          ),
        );
      },
      childCount: requests.length
      )
    );
  }



   @override
   void initState() {
     // TODO: implement initState
     getLoc();
     super.initState();
     readLocal();
     updateRequests();
     BitmapDescriptor.fromAssetImage(
         ImageConfiguration(devicePixelRatio: 2.5),
         'assets/images/pin.png').then((onValue) {
       pinLocationIcon = onValue;
     });
     checkRequest();
     setState(() {

     });
   }


   @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Material(
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  GoogleMap(
                      markers: _markers,
                      polylines: _polylines,
                      compassEnabled: true,
                      myLocationButtonEnabled: true,
                      //myLocationEnabled: true,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 11.0,
                      )
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: colors[5],
                        centerTitle: true,
                        expandedHeight: 110,
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Profile Picture
                            Container(
                              child: Center(
                                child: Stack(
                                  children: <Widget>[
                                    Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                          width: 70.0,
                                          height: 70.0,
                                          padding: EdgeInsets.all(10.0),
                                        ),
                                        imageUrl: pic,
                                        width: 70.0,
                                        height: 70.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )

                                  ],
                                ),
                              ),
                              width: double.infinity,
                              margin: EdgeInsets.all(10.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("$firstName $lastName",
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    color: colors[4]
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("$role",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color: colors[4]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      role == 'Passenger'
                     ? SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              riderBody()
                            ]
                          ))
                          : driverBody2()
                    ],
                  ),
                ],
              )
            ),
            isRequesting
            ? Container(
              color: colors[4],
              child: checkResponse()
            )
                : Container(),
            isLoading
            ? Container(
              color: colors[4],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: colors[3],
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Loading please wait...",
                        style: TextStyle(
                            color: colors[3]
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }
}
