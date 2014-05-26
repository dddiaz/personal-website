

<!DOCTYPE html>
<html>
  <head>
    <title>Drawing tools</title>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta charset="utf-8">
    <!---<link href="/maps/documentation/javascript/examples/default.css" rel="stylesheet">--->
    <style>
      html, body, #map-canvas {
        margin: 0;
        padding: 0;
        height: 100%;
      }
	  
	  #panel{
height:34px;
width: 500px;
background-color:#fff;
position:absolute;
border: 1px solid #4D90FE;
padding-left:5px;
left: 100px;
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
left:100px;
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
 
        $("#slidingDiv").show();//changed thias from init on hide to init on show
        $(".show_hide").show();
 
    $('.show_hide').click(function(){
    $("#slidingDiv").slideToggle();
    });
 
});
 
</script>
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=drawing"></script>
    <script>
	var map;
	google.maps.visualRefresh = true;
	
function initialize() {
  var mapOptions = {
    center: new google.maps.LatLng(33.6461322, -117.8428335),
    zoom: 14,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
    mapOptions);

  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: google.maps.drawing.OverlayType.MARKER,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: [
        google.maps.drawing.OverlayType.MARKER,
        google.maps.drawing.OverlayType.CIRCLE,
        google.maps.drawing.OverlayType.POLYGON,
        google.maps.drawing.OverlayType.POLYLINE,
        google.maps.drawing.OverlayType.RECTANGLE
      ]
    },
    markerOptions: {
      icon: 'images/beachflag.png'
    },
	polygonOptions: {
    	editable: true
    },
    circleOptions: {
      fillColor: '#ffff00',
      fillOpacity: 1,
      strokeWeight: 5,
      clickable: false,
      editable: true,
      zIndex: 1
    }
  });
  drawingManager.setMap(map);
  
  //var latarray = newShape.getPath().getArray()[0].lat();
  
}

function createLink(){
	var latarray = newShape.getPath().getArray()[0].lat();
	alert(latarray);
}



google.maps.event.addDomListener(window, 'load', initialize);

    </script>
  </head>
  <body>
    <div id="panel"> 
    	<!--<input id="address" size="57" type="textbox" value="Test Box Creator">
    	<INPUT TYPE="image" SRC="search.gif" ALT="Create Link" value="Geocode" onclick="createLink()">-->
        <center><p><a href="#" onClick="createLink();">Create Links</a></p></center>
	</div>

  	<div id="map-canvas"></div>

	<div id="slidingDiv"> 
 		<div align="right"> <a href="#" class="show_hide">Close</a><br/></div>
		<div align="left">  Click on the map to generate an overlay then click the button to generate the link
        <form method="post" accept-charset="utf-8" id="map_form">
    	<input type="text" name="vertices" value="" id="vertices"  />
    	<input type="button" name="save" value="Save!" id="save"  />
		</form>
        </div>
	</div>
  </body>
</html>

