<!DOCTYPE html>
<html>
  <head>
    <title>Not the New Google Maps</title>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
	<link href='http://fonts.googleapis.com/css?family=Roboto+Condensed' rel='stylesheet' type='text/css'>
    <style>
      html, body, #map-canvas {
        margin: 0;
        padding: 0;
        height: 100%;
      }
	  
#panel{
height:34px;
background-color:#fff;
position:absolute;
border: 1px solid #4D90FE;
padding-left:5px;
left:20px;
top:10px;
z-index:1;
-webkit-box-shadow: 2px 2px 4px #ccc;
-moz-box-shadow:    2px 2px 4px #ccc;
box-shadow:         2px 2px 4px #ccc;
}	  

#address{
  vertical-align: top;
  padding:5px;
  border: none;
  font-family: 'Roboto Condensed', sans-serif;
  font-style: normal;
  font-size:16px;
}


	  
#slidingDiv {
  font-family: 'Roboto Condensed', sans-serif;
  font-style: normal;
  font-weight: 400;
background-color:#fff;
position:absolute;
left:20px;
width:385px;

top:50px;
z-index:1;
padding-top:5px;
padding-left:20px;
padding-right:20px;
padding-bottom:20px;
-webkit-box-shadow: 2px 2px 4px #ccc;
-moz-box-shadow:    2px 2px 4px #ccc;
box-shadow:         2px 2px 4px #ccc;
}
 
.show_hide {
    display:none;
}
    </style>
	
	
	
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.js" type="text/javascript"></script>
<script type="text/javascript">
 
$(document).ready(function(){
 
        $("#slidingDiv").hide();
        $(".show_hide").show();
 
    $('.show_hide').click(function(){
    $("#slidingDiv").slideToggle();
    });
 
});
 
</script>
	
	
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false"></script>
    <script>
var geocoder;
var map;
google.maps.visualRefresh = true;
function initialize() {
geocoder = new google.maps.Geocoder();

  var mapOptions = {
    zoom: 14,
    center: new google.maps.LatLng(33.6452837040672, -117.84285763988113),
	panControl: false,
	streetViewControl: false,
	zoomControl: true,
    zoomControlOptions: {
        style: google.maps.ZoomControlStyle.SMALL,
        position: google.maps.ControlPosition.RIGHT_BOTTOM
    },

    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);
	  
	google.maps.event.addListener(map,'click',function(event) {
	$("#slidingDiv").hide();
	$(".show_hide").show();
	$("#slidingDiv").slideToggle();
	
	var latlng = new google.maps.LatLng(event.latLng.lat(), event.latLng.lng());
	
	 geocoder.geocode({'latLng': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        document.getElementById('slidingDiv').innerHTML= (results[1].formatted_address) +  "<br><br> <img src=\"http://maps.googleapis.com/maps/api/streetview?size=385x100&location=" + latlng + "&heading=151.78&pitch=-0.76&sensor=false\">"      
      } else {
        alert('No results found');
      }
    } else {
      alert('Geocoder failed due to: ' + status);
    }
  });
  
	

    })
	  

   google.maps.event.addListener(map, 'dragend', function() { 
  $("#slidingDiv").hide();
  });	  
	  
}

function codeAddress() {
  var address = document.getElementById('address').value;
  geocoder.geocode( { 'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
    } else {
      alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}



google.maps.event.addDomListener(window, 'load', initialize);

    </script>
  </head>
  <body>
  
<div id="panel"> 
    <input id="address" size="57" type="textbox" value="University Of California Irvine">
    <INPUT TYPE="image" SRC="search.gif" ALT="SUBMIT" value="Geocode" onclick="codeAddress()">

</div>

  <div id="map-canvas"></div>
	


<div id="slidingDiv"> 
 <div align="right"> <a href="#" class="show_hide">Close</a><br/></div>
<div align="left">  Using the new Google Maps index card style rather than an information window </div>
</div>

  </body>
</html>

