/////////////////////////////////Map Variables//////////////////////////////////////////

var map;
var infowindow = false;
var infowindow1 = false;

var initialized = false;
var lotName;
var markers;

var allLotsShowing = true;
var allBuildingsShowing = false;
var allKiosksShowing = false;
var allPermitDispensersShowing = false;
var allZotWheelsShowing = false;

var loadBuildings = true;
var loadKiosks = true;
var loadPermitDispensers = true;
var loadZotWheels = true;

var templength = 0; //for some reason temp.legnth has been breaking// fixed

var directionsDisplay;
var directionsService = new google.maps.DirectionsService();

////prev variables from imap.js
// Array of GMarkers buildings, lots, misc map items
var b_markers = [];
var l_markers = [];
var kiosk_markers = [];
var disp_markers = [];
var cs_markers = [];
var zw_markers = [];
var serv_markers = [];
// Used for the clickable map
var everything = [];

var last_lot;
var last_building;

var k_cleared = true;
var zw_cleared = true;
var cs_cleared = true;
var disp_cleared = true;
var serv_cleared = true;

// Boolean: if a misc item has its info bubble showing
var showing;

var permit_id = null;
var permit_type = null;
var permit_name = null;

var currentLot_name = null;
var currentLot_id = null;
var currentBldgInfo = null;

var valid_lots = [];

var point;

var directionsService = new google.maps.DirectionsService();
var directionsRender;

var info_open = false;

var all_lots_showing = false;
var all_buildings_showing = false;

var CurAffilText = '';

var geocoder = new google.maps.Geocoder();

var welc_window;


//////////////////////////Prototypes//////////////////////////////////////////////////////////
// Prototypes that reflect some missing functions from google maps v2 that are not in v3
google.maps.LatLng.prototype.distanceFrom = function(newLatLng) { 
  //var R = 6371; // km (change this constant to get miles) 
  var R = 6371000; // meters 
  var lat1 = this.lat(); 
  var lon1 = this.lng(); 
  var lat2 = newLatLng.lat(); 
  var lon2 = newLatLng.lng(); 
  var dLat = (lat2-lat1) * Math.PI / 180; 
  var dLon = (lon2-lon1) * Math.PI / 180; 
  var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math.PI / 180 ) * Math.cos(lat2 * Math.PI / 180 ) * Math.sin(dLon/2) * Math.sin(dLon/2); 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; 
  return d; 
} 

////////////////////////////////////MapFunctions///////////////////////////////////////////////
//Initializing the map
google.maps.visualRefresh = true;
function initialize() {
		//to render directions on map
		directionsDisplay = new google.maps.DirectionsRenderer();

		var latlng = new google.maps.LatLng(33.6461322, -117.8428335);
        var mapOptions = {
          center: latlng,
          zoom: 16,
          mapTypeId: google.maps.MapTypeId.HYBRID, streetViewControl: true,
		  	navigationControlOptions: {
				style: google.maps.NavigationControlStyle.SMALL, 
				position: google.maps.ControlPosition.RIGHT_CENTER}, 
		  	mapTypeControlOptions: {
				style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
				position: google.maps.ControlPosition.RIGHT_CENTER},
			zoomControlOptions: {
				style: google.maps.ZoomControlStyle.SMALL,
				position: google.maps.ControlPosition.RIGHT_CENTER},
			panControl: false
        };
        map = new google.maps.Map(document.getElementById("mapCanvas"),mapOptions);
		 directionsDisplay.setMap(map);
		
		loadAllLots(); //load all lots using jquery
		//loadAllLots();	//working
		//loadAllBuildings();	//working
		//loadMarkersTest();
					
		//google.maps.event.addDomListener(window, 'load', initialize);
					
}

//Welcome Window
function showWelcomeWindow(){
	var welcome = "<div id='info_bubble'><div style='width:100%; padding:5px 5px 10px 5px;'><div style='float:left;width:58px;'><img src='imap/icons/logo_icon.png' /></div><div style='margin-top:5px;'><div style='padding-bottom:3px; font-size:12px; text-align:left;'>This is a Prototype of an interactive map <br> <br>Select from the options at the top to show different lots or features</div></div><div style='clear:both'></div></div>";
	
	welc_window = new google.maps.InfoWindow({
		position: new google.maps.LatLng(33.6452837040672, -117.84285763988113),
		content: welcome
	});	
	
	welc_window.open(map);	
	
	google.maps.event.addListener(map, 'click', function(event) {
		welc_window.close();															  																  
	});	

}

function closeWelcomeWindow()
{
	if (welc_window) {
		welc_window.close();	
	}
}

////////////////////////////////////////////////Functions needed to place markers on map (for the dropdown menu "show?"////////////////////

//////////////////parking lot functions///////////////////////////
//load all parking lots to show on map load
function loadAllLots(){
	jQuery.get("assets/xml/allLots.xml", {}, function(data) {
      jQuery(data).find("lot").each(function() {
        var marker = jQuery(this);
        var latlng = new google.maps.LatLng(parseFloat(marker.find('LATITUDE').text()),
                                    parseFloat(marker.find('LONGITUDE').text()));
		var lotName = marker.find("LOT_NAME").text();
		var ID = marker.find("ID").text()
        var marker = createAllLotsMarker(lotName, latlng, ID);
		l_markers.push(marker);
		everything.push(marker);
     });
    });
}
//create markers for all Lots
function createAllLotsMarker(name, latlng, ID) {
	
	var contentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">'+name+'</h1>'+
      '<div id="bodyContent">'+
      '<p>The Lot ID to be Passed is:'+ID+'</p>'+
      '<p>Stall Info: <a href="#StallInventoryModal"'+
      'onclick=showStallInventory('+ID+');>Link</a> '+
      '</p>'+
      '</div>'+
      '</div>';
	
    var marker = new google.maps.Marker({clickable: true,
		visible: true, position: latlng, map: map});
    google.maps.event.addListener(marker, "click", function() {
      if (infowindow) infowindow.close();
      infowindow = new google.maps.InfoWindow({content: contentString});
      infowindow.open(map, marker);
    });
    return marker;
}
//when show parking lots dropdown menu item clicked, toggle this
function toggleP(){
	if(allLotsShowing){
		for(var i=0; i<=l_markers.length -1; i++){
			l_markers[i].setVisible(false);
			allLotsShowing = false;	
		}
	}
	else{
		for(var i=0; i<=l_markers.length -1; i++){
			l_markers[i].setVisible(true);
			allLotsShowing = true;	
		}
	}
}

function showStallInventory(lotID){
 
		var ins = new proxy();
		
		ins.setCallbackHandler(function (info){			
										 
			if(info.DATA[0] != null){
				var stallCountHtml = "<u>Stall Inventory for lot" + lotID + ":</u><br /><table class='stall_table' cellpadding='2'><tr><td><b>Stall type</b></td><td><b>Quantity</b></td></tr>";
				for(i=0;i<info.DATA.length ;i++){
					stallCountHtml += "<tr><td>" + (info.DATA[i][info.COLUMNS.findIdx('COMMON_NAME')]+"</td>");
					stallCountHtml += "<td align='right'>" +(info.DATA[i][info.COLUMNS.findIdx('QUANTITY')]+"<td></tr>");
					}

				var ModDate = info.DATA[0][info.COLUMNS.findIdx('LASTMODDATE')].split(" ");
				
				stallCountHtml += "<tr><td>&nbsp;</td></tr>";
				stallCountHtml += "<tr><td> Last Updated: " + ModDate[0].replace(",", "") + ' ' + ModDate[1] + ', ' + ModDate[2] + "</td></tr>";
				//document.getElementById('stallCountList').innerHTML = stallCountHtml + "</table>";
				document.getElementById("StallInventoryModalInfo").innerHTML = stallCountHtml + "</table>";
				
				//document.mapSelectForm.action.value = 'stallCounts';
				//updateAction();
			}
			else{
				//document.getElementById('stallCountList').innerHTML = 'No stall inventory data for selected lot. Please select another lot.';
				document.getElementById("StallInventoryModalInfo").innerHTML = 'No stall inventory data for selected lot. Please select another lot.';
			}
			
		});

		ins.getLotInfo(lotID);
		$('#StallInventoryModal').modal('show');
	
}

///////////////////////building functions
//load allbuildingss to show on map load
function jLoadAllBuildings(){
	jQuery.get("assets/xml/allBuildings.xml", {}, function(data) {
      jQuery(data).find("building").each(function() {
        var marker = jQuery(this);
        var latlng = new google.maps.LatLng(parseFloat(marker.find('LATITUDE').text()),
                                    parseFloat(marker.find('LONGITUDE').text()));
		var buildingName = marker.find("BUILDING_NAME").text();
        var marker = createAllBuildingMarkers(buildingName, latlng);
		b_markers.push(marker);
		everything.push(marker);
     });
    });
}

function loadAllBuildings(){
	downloadUrl("assets/xml/allBuildings.xml", function(data) {
		var markers = data.documentElement.getElementsByTagName("building");
		for (var i = 0; i < markers.length; i++) {
			var latlng = new google.maps.LatLng(parseFloat(markers[i].getAttribute("latitude")),parseFloat(markers[i].getAttribute("longitude")));
			//update this!!!!!!
			var buildingName = markers[i].getAttribute("buildingName");
			//var buildingName = "test123";
			//var buildingName = markers[i].getAttribute("id");
			var buildingID = markers[i].getAttribute("buildingid");
			var marker = createAllBuildingMarkers(buildingName, latlng, buildingID); 
			b_markers.push(marker);
			everything.push(marker);
			}
		});
}
//creat markers for all buildings
function createAllBuildingMarkers(name, latlng, buildingid) {
	
	var contentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">'+name+'</h1>'+
      '<div id="bodyContent">'+
      '<p>Test Body Content</p>'+
      '<p>Accesability Info: <a href="#accessabilityModal"'+
      'onclick=b_showADAInfo('+buildingid+');>Link</a> '+
      '(last visited June 22, 2009).</p>'+
      '</div>'+
      '</div>';

	
    var marker = new google.maps.Marker({clickable: true,
		visible: true, position: latlng, map: map});
    google.maps.event.addListener(marker, "click", function() {
      if (infowindow) infowindow.close();
      infowindow = new google.maps.InfoWindow({content: contentString});
      infowindow.open(map, marker);
    });
    return marker;
}

//when show buildings dropdown menu item clicked, toggle this
function toggleb(){
	if(allBuildingsShowing){
		for(var i=0; i<=b_markers.length -1; i++){
			b_markers[i].setVisible(false);
			allBuildingsShowing = false;	
		}
	}
	else{
		if (loadBuildings){
			jLoadAllBuildings();
			allBuildingsShowing = true;
		}
		else{
			for(var i=0; i<=b_markers.length -1; i++){
				b_markers[i].setVisible(true);
				allBuildingsShowing = true;	
			}
		}
	}
}


function b_showADAInfo(buildingID) {
	
		//$('#accessabilityModal').modal('show');
		
		//document.getElementById("ADAModalInfo").innerHTML = buildingID;
		
		var instance = new proxy();		

		instance.setCallbackHandler(function (info){	
										
					info.MAIN_ENTRANCE = (info.MAIN_ENTRANCE) ? "Yes" : "No" ;
					info.REAR_ENTRANCE = (info.REAR_ENTRANCE) ? "Yes" : "No" ;
					info.ELEVATOR = (info.ELEVATOR) ? "Yes" : "No" ;
					info.RAMPS = (info.RAMPS) ? "Yes" : "No" ;
					var accessibilityHtml = "<u>Accessibility Info for " + buildingID + ":</u><br /><table class='stall_table' cellpadding='2'>" +
							   "<tr><td><b>Main Entrance: </b></td><td>" + info.MAIN_ENTRANCE + "</td></tr>" +
							   "<tr><td><b>Rear Entrance: </b></td><td>" + info.REAR_ENTRANCE + "</td></tr>" +
							   "<tr><td><b>Elevator: </b></td><td>" + info.ELEVATOR + "</td></tr>" +
							   "<tr><td><b>Ramps: </b></td><td>" + info.RAMPS + "</td></tr>" +
							   "<tr><td><hr>" + "</td></tr>" +
							   "<tr><td><b>Closest Lot: </b></td><td><a href='##' onClick='viewLot("+ info.LOT_ID +",true)'>" + info.CLOSEST_LOT_1 + "</a></td></tr>" +
							   "<tr><td><b>Distance: </b></td><td>" + info.DISTANCE  + "</td></tr>" +
							   "<tr><td><b>Total Disabled Stalls/ Van Accessible Stalls </b></td><td>" + info.TOTAL_D_STALLS_1 + "</td></tr>" +
							   "<tr><td><hr>" + "</td></tr>" +
							   "<tr><td><b>Alternative Lot: </b></td><td>" + info.CLOSEST_LOT_2 + "</td></tr>" +
							   "<tr><td><b>Total Disabled Stalls/ Van Accessible Stalls </b></td><td>" + info.TOTAL_D_STALLS_2 + "</td></tr>" +
							   "<tr><td><b>Special Notes: </b></td><td>" + info.NOTES +"</td></tr>" +
							   "</table>";	
							   				   
					document.getElementById("ADAModalInfo").innerHTML = accessibilityHtml;
					//alert("you got here")
				

				//infowindow.setContent(markerHtml);
				//$('#accessabilityModal').modal('show');
			
			}
		);
	
		//instance.getADAInfo(buildingID);
		//to hard test weather the building id of 7 will give the right ada info	
		//instance.getADAInfo(7);	
		instance.getADAInfo(127);	
	
		//document.getElementById("ADAModalInfo").innerHTML = accessibilityHtml;
		
		$('#accessabilityModal').modal('show');
}


function b_showADAInfoTest(buildingID){

//alert("you got here");

  $.ajax({
  // the location of the CFC to run
    url: "map.cfc?method=getADAInfo&returnformat=json"
  // send a GET HTTP operation
  , type: "get"
  // tell jQuery we're getting JSON back
  , dataType: "json"
  // send the data to the CFC
  , data: {
    // the method in the CFC to run
      //method: "getADAInfo"
    /*
      send other arguments to CFC
    */
    // send the ID entered by the user
    //, buildingNumber: "7"
	buildingNumber: "7"
  }
  // this gets the data returned on success
  , success: function (data){
    // this uses the "jquery.field.min.js" library to easily populate your form with the data from the server
    //$("#frmMain").formHash(data);
	alert("hey it worked")
  }
  // this runs if an error
  , error: function (xhr, textStatus, errorThrown){
    // show error
    alert(errorThrown);
  }
});

}

///////////////////////kiosk functions
//load kiosks to show on map load
function jLoadAllKiosks(){
	jQuery.get("assets/xml/kiosks.xml", {}, function(data) {
      jQuery(data).find("kiosk").each(function() {
        var marker = jQuery(this);
        var latlng = new google.maps.LatLng(parseFloat(marker.find('LATITUDE').text()),
                                    parseFloat(marker.find('LONGITUDE').text()));
		var kioskName = marker.find("DESCRIPTION").text();
        var marker = createAllKioskMarkers(kioskName, latlng);
		kiosk_markers.push(marker);
		everything.push(marker);
     });
    });
}

//create markers for all kiosks
function createAllKioskMarkers(name, latlng) {
	var ContentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">'+name+'</h1>'+
      '<div id="bodyContent">'+
      '<p>Test Body Content</p>'+
      '</div>'+
      '</div>';
    var marker = new google.maps.Marker({clickable: true,
		visible: true, position: latlng, map: map});
    google.maps.event.addListener(marker, "click", function() {
      if (infowindow) infowindow.close();
      infowindow = new google.maps.InfoWindow({content: ContentString});
      infowindow.open(map, marker);
    });
    return marker;
}

//when show kiosks dropdown menu item clicked, toggle this
function toggleKiosks(){
	if(allKiosksShowing){
		for(var i=0; i<=kiosk_markers.length -1; i++){
			kiosk_markers[i].setVisible(false);
			allKiosksShowing = false;	
		}
	}
	else{
		if (loadKiosks){
			jLoadAllKiosks();
			allKiosksShowing = true;
		}
		else{
			for(var i=0; i<=kiosk_markers.length -1; i++){
				kiosk_markers[i].setVisible(true);
				allKiosksShowing = true;	
			}
		}
	}
}

///////////////////////permit dispenser functions
//permit dispensers to show on map 
function loadAllPermitDispensers(){
	jQuery.get("assets/xml/permitDisp.xml", {}, function(data) {
      jQuery(data).find("dispenser").each(function() {
        var marker = jQuery(this);
        var latlng = new google.maps.LatLng(parseFloat(marker.find('LATITUDE').text()),
                                    parseFloat(marker.find('LONGITUDE').text()));
		var dispName = marker.find("DESCRIPTION").text();
        var marker = createAllPermitDispensers(dispName, latlng);
		disp_markers.push(marker);
		everything.push(marker);
     });
    });
}
//create permit dispenser marker
function createAllPermitDispensers(name, latlng) {
	var ContentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">'+name+'</h1>'+
      '<div id="bodyContent">'+
      '<p>Test Body Content for permit disp</p>'+
      '</div>'+
      '</div>';
    var marker = new google.maps.Marker({clickable: true,
		visible: true, position: latlng, map: map});
    google.maps.event.addListener(marker, "click", function() {
      if (infowindow) infowindow.close();
      infowindow = new google.maps.InfoWindow({content: ContentString});
      infowindow.open(map, marker);
    });
    return marker;
}

//when permit dispensers dropdown menu item clicked, toggle this
function togglePermitDispensers(){
	if(allPermitDispensersShowing){
		for(var i=0; i<=disp_markers.length -1; i++){
			disp_markers[i].setVisible(false);
			allPermitDispensersShowing = false;	
		}
	}
	else{
		if (loadPermitDispensers){
			loadAllPermitDispensers();
			allPermitDispensersShowing = true;
		}
		else{
			for(var i=0; i<=disp_markers.length -1; i++){
				disp_markers[i].setVisible(true);
				allPermitDispensersShowing = true;	
			}
		}
	}
}


//Zot wheels markers/////////////////////////////////////////////////////
function jLoadAllZotWheels(){
	jQuery.get("assets/xml/zotWheels1.xml", {}, function(data) {
      jQuery(data).find("wheel").each(function() {
        var marker = jQuery(this);
		var gps = marker.find("gps").text();
		var n = gps.split(",");
		
        var latlng = new google.maps.LatLng(parseFloat(n[0]),
                                    parseFloat(n[1]));
		var wheelName = marker.find("note").text();
		var stalls = marker.find("stalls").text();
		var bikes = marker.find("bikes").text();
		var lastupdated = marker.find("lastHeartbeat").text();
        var marker = createAllZotWheelsMarkers(wheelName, latlng, bikes, stalls, lastupdated);
		zw_markers.push(marker);
		everything.push(marker);
     });
    });
	jQuery.get("assets/xml/zotWheels2.xml", {}, function(data) {
      jQuery(data).find("wheel").each(function() {
        var marker = jQuery(this);
		var gps = marker.find("gps").text();
		var n = gps.split(",");
		
        var latlng = new google.maps.LatLng(parseFloat(n[0]),
                                    parseFloat(n[1]));
		var wheelName = marker.find("note").text();
		var stalls = marker.find("stalls").text();
		var bikes = marker.find("bikes").text();
		var lastupdated = marker.find("lastHeartbeat").text();
        var marker = createAllZotWheelsMarkers(wheelName, latlng, bikes, stalls, lastupdated);
		zw_markers.push(marker);
		everything.push(marker);
     });
    });
	jQuery.get("assets/xml/zotWheels3.xml", {}, function(data) {
      jQuery(data).find("wheel").each(function() {
        var marker = jQuery(this);
		var gps = marker.find("gps").text();
		var n = gps.split(",");
		
        var latlng = new google.maps.LatLng(parseFloat(n[0]),
                                    parseFloat(n[1]));
		var wheelName = marker.find("note").text();
		var stalls = marker.find("stalls").text();
		var bikes = marker.find("bikes").text();
		var lastupdated = marker.find("lastHeartbeat").text();
        var marker = createAllZotWheelsMarkers(wheelName, latlng, bikes, stalls, lastupdated);
		zw_markers.push(marker);
		everything.push(marker);
     });
    });
	jQuery.get("assets/xml/zotWheels4.xml", {}, function(data) {
      jQuery(data).find("wheel").each(function() {
        var marker = jQuery(this);
		var gps = marker.find("gps").text();
		var n = gps.split(",");
		
        var latlng = new google.maps.LatLng(parseFloat(n[0]),
                                    parseFloat(n[1]));
		var wheelName = marker.find("note").text();
		var stalls = marker.find("stalls").text();
		var bikes = marker.find("bikes").text();
		var lastupdated = marker.find("lastHeartbeat").text();
        var marker = createAllZotWheelsMarkers(wheelName, latlng, bikes, stalls, lastupdated);
		zw_markers.push(marker);
		everything.push(marker);
     });
    });
}

function createAllZotWheelsMarkers(name, latlng, bikes, stalls, lastupdated) {
	var ContentString = '<div id="content">'+
      '<div id="siteNotice">'+
      '</div>'+
      '<h1 id="firstHeading" class="firstHeading">'+name+'</h1>'+
      '<div id="bodyContent">'+
      '<p>There are currently '+ bikes +'/' + stalls + ' bikes available </p>'+
	  '<p>Last Updated: '+ lastupdated +'</p>'+
      '</div>'+
      '</div>';
    var marker = new google.maps.Marker({clickable: true,
		visible: true, position: latlng, map: map});
    google.maps.event.addListener(marker, "click", function() {
      if (infowindow) infowindow.close();
      infowindow = new google.maps.InfoWindow({content: ContentString});
      infowindow.open(map, marker);
    });
    return marker;
}

function toggleZotWheels(){
	if(allZotWheelsShowing){
		for(var i=0; i<=zw_markers.length -1; i++){
			zw_markers[i].setVisible(false);
			allZotWheelsShowing = false;	
		}
	}
	else{
		if (loadZotWheels){
			jLoadAllZotWheels();
			allZotWheelsShowing = true;
		}
		else{
			for(var i=0; i<=zw_markers.length -1; i++){
				zw_markers[i].setVisible(true);
				allZotWheelsShowing = true;	
			}
		}
	}
}




//////////////////////////////////functions needed for the where to park menu button//////////////////////////////////////////////////
function whereToParkModal(){
	    $('#whereToParkModal').modal('show');
}

function whereToParkModalInfo(){
	    $('#whereToParkModalInfo').modal('show');
}

// Change the visitor type
// -------------------------
function changeVisitorType(type){
	
	$('#whereToParkModal').modal('hide');
	
	valid_lots = null;
	permit_type = null;
	permit_name = null;
	
	var arr = null;
	if (type == 2) {
		arr  = 'student_p'; 
	}
	else if ( type == 1) {
		arr = 'visitor_p'; 
	}
	else if (type == 3) {
		arr = 'staff_p'; 
	}
	else if (type == 4) {
		arr = 'service_p'; 
	}
	else { 
		document.getElementById("WhereToParkModalInfo-List").innerHTML = "<p></p>";
		return;
	}
	
	document.getElementById("WhereToParkModalInfo").innerHTML = "<p></p>"
	//document.getElementById("WhereToParkModalInfo-List").innerHTML = "<select><option value = 'test'>Test</option><select>"
	
	var temp = [];
	
	var filestring = "assets/xml/";
	var filestring = filestring + arr + ".xml"
	jQuery.get(filestring, {}, function(data) {
      jQuery(data).find("lot").each(function() {
        var marker = jQuery(this);
		var permit = new Object();
		permit.permitOrGroup = marker.find("PERMITORGROUP").text();
		permit.id = marker.find("ID").text();
		permit.type = marker.find("TYPE").text();
		permit.description = marker.find("DESCRIPTION").text();
		temp.push(permit);
		templength++;
		console.log("number in jquery loop" + templength);
		});
		createOptions(temp);
    });
	
	console.log("number after jquery loop" + templength);
	
}

function appendStringToModal(string){
	var txt1 = string;
	existingdiv1 = document.getElementById('WhereToParkModalInfo');
	$("#WhereToParkModalInfo").append(txt1);
	//$("existingdiv1").append(txt1);
	whereToParkModalInfo();
}

function createOptions(temp){
	var x = temp.length;
	console.log("number in createoptions" + x);
	var appendString = "<select>";
	var add = '';
	for(var i=0; i < x; i++){ 
		 if (temp[i].type != '') {
			//add = "<option value = 'test'>Test</option>";
			add = "<option value = 'test'>" + temp[i].description + "</option>";
			//appendString = appendString + "<option value = 'test'>Test</option>";
		 }
		 else {
			appendString = appendString;
		 }
		 appendString = appendString + add;
	}
	appendString = appendString + "</select>";
	//document.getElementById('WhereToParkModalInfo-List').innerHTML = apppendString
	appendStringToModal(appendString);
}

function changePermitType(p_id, type){
	valid_lots = [];
	if(p_id != 'none'){
		permit_type = p_id; 
		permit_name = type; 
		
		document.getElementById("WhereToParkModalInfo").innerHTML = "<p>You are allowed to park in the following lots:</p>";
		$('#whereToParkModal').modal('hide');
		$('#whereToParkModal-Visitor').modal('show');
		var instance = new proxy();
		instance.setCallbackHandler(function(info){
			if(info.DATA.length == 0){
				//document.getElementById("lot_list").innerHTML = "<p>We're sorry, your permit does not appear to be valid anywhere on campus. Check your selection and try again.</p>";
				document.getElementById("WhereToParkModalInfo").innerHTML = "<p>Please contact Transportation and Distribution Services at (949) 824-PARK (7275) to receive information regarding this permit type.</p>";
			}
			else{
				for(var i=0;i<info.DATA.length ;i++){
					//alert(info.DATA[i][info.COLUMNS.findIdx('ID')]);
					for(var k=0; k < l_markers.length; k++){
						//alert(l_markers[k].lot_id);
						if(l_markers[k].id == info.DATA[i][info.COLUMNS.findIdx('ID')]){
							valid_lots[i] = l_markers[k];
							//alert(l_markers[k].lot_id + " equal to query " + info.DATA[i][info.COLUMNS.findIdx('ID')]);
							var rowClass = (i % 2 == 0) ? 'evenrow' : 'oddrow';
							document.getElementById("WhereToParkModalInfo-List").innerHTML += "<div id='lot_list' class='"+ rowClass +"' onClick='viewLot("+ valid_lots[i].id +", true)'>"+ valid_lots[i].title +"</div>";
							break;
						}
					}
				}
			}	
			
			//b_updateMarker(currentBldgInfo); // update the building info bubble to reflect a change in permit type
			//updateCurAffilation(); //Update Current Affiliation button text to reflect change in permit type
			
			// If the parking lots are displayed, update them to display the lots appropriate to the newly selected permit
			//if (all_lots_showing == true) {
				//showParkingLots("valid");
			//}
		});
		var permitOrGroup = p_id.substring(0,1);
		var permitId = p_id.substring(1);
		if (permitOrGroup == 'P' || permitOrGroup == 'G') {
			instance.getAllowedParking(permitOrGroup, permitId);
		}
	}
	else{
		valid_lots = null;
		permit_type = null;
		permit_name = null;
		//document.getElementById("p_type").innerHTML = type;
		document.getElementById("lot_list").innerHTML = "<p></p>";
		
		// If no permit type was selected and parking lots are displayed, show all parking lots
		if (all_lots_showing == true) {
			showParkingLots("all");
		}
		
		b_updateMarker(currentBldgInfo); // update the building info bubble to reflect a change in permit type
		updateCurAffilation(); //Update Current Affiliation button text to reflect change in permit type
	}

}


//////////////////////////////////functions needed for the directions menu button//////////////////////////////////////////////////
function directionsModal(){
	    $('#directionsModal').modal('show');
		//document.getElementById("permit_affiliation").innerHTML = "test hjsdgbjksdbsdjlkgdbjsfjgjslfdg";
}

function calcRoute() {
  var start = document.getElementById("start").value;
  var end = document.getElementById("end").value;
  var request = {
    origin:start,
    destination:end,
    travelMode: google.maps.TravelMode.DRIVING
  };
  directionsService.route(request, function(result, status) {
    if (status == google.maps.DirectionsStatus.OK) {
		//$('#directionsModal').modal('hide');
		//$('#directionsFromGoogleModal').modal('show');
      directionsDisplay.setDirections(result);
    }
  });
}

function accessabilityModal(){
	    $('#accessabilityModal').modal('show');
		//document.getElementById("permit_affiliation").innerHTML = "test hjsdgbjksdbsdjlkgdbjsfjgjslfdg";
}
