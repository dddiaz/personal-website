<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Interactive Map</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Interactive map for parking and distribution services">
    <meta name="author" content="UCI Parking And Distribution - Daniel Diaz 2013">

    <!-- Le styles -->
    <link href="assets/css/bootstrap.css" rel="stylesheet">
    <link href="assets/css/bootstrap-responsive.css" rel="stylesheet">
    <!--Custom Map/navbar CSS-->
    <link href="assets/css/customMap.css" rel="stylesheet">
    <!--Other custom css tweaks-->
    <link href="assets/css/tweaks.css" rel="stylesheet">
 
    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="../assets/js/html5shiv.js"></script>
    <![endif]-->
    
    <!--Import jquery/googlemaps api/and map functions-->
    <script type="text/javascript"src="assets/js/jquery.js"></script>
    <script type="text/javascript"src="https://maps.googleapis.com/maps/api/js?sensor=true"></script>
    <script type="text/javascript"src="assets/js/mapFunctions/mapFunctions.js"></script> 
    <!--Create XML Files-->
    <!--- CF
    <cfinvoke component="map" method="createAllLots"> </cfinvoke>  
    <cfinvoke component="map" method="createAllBuildings"> </cfinvoke>  
    <cfinvoke component="map" method="createKiosks"> </cfinvoke>  
    <cfinvoke component="map" method="createPermitDisp"> </cfinvoke>  
    <cfinvoke component="map" method="createZotWheelsXML"> </cfinvoke>
    <cfinvoke component="map" method="alwaysCreateXML"> </cfinvoke>
    --->
    <!--Setting the new AJAX proxy-->
	<!---<cfajaxproxy cfc="map" jsclassname="proxy" />--->
    
</head>
  <!--Initialize Map-->
  <body onLoad="initialize()">
      
    <!-- NAVBAR
    ================================================== -->
    <div class="navbar-wrapper">
      <!-- Wrap the .navbar in .container to center it within the absolutely positioned parent. -->
      <div class="container">
        <div class="navbar navbar-inverse">
          <div class="navbar-inner">
            <!-- Responsive Navbar Part 1: Button for triggering responsive navbar (not covered in tutorial). Include responsive CSS to utilize. -->
            <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="brand" href="#" onClick="showWelcomeWindow();">Interactive Map</a>
            <!-- Responsive Navbar Part 2: Place all navbar contents you want collapsed withing .navbar-collapse.collapse. -->
            <div class="nav-collapse collapse">
              <ul class="nav">
              <li class="dropdown">
                      <a id="drop1" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">Show? <b class="caret"></b></a>
                      <ul class="dropdown-menu" role="menu" aria-labelledby="drop1">
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#" onClick="toggleP();">Parking Lots</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#" onClick="toggleb();">Buildings</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#" onClick="toggleKiosks();">Information Kiosks</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#" onClick="togglePermitDispensers();">Permit Dispensers</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#">Carshare</a></li>
                        <li role="presentation" class="divider"></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#" onClick="toggleZotWheels();">ZotWheels</a></li>
                      </ul>
                    </li>
              <li><a href="#whereToParkModal" onClick = "whereToParkModal();">Where To Park?</a></li>
              <li><a href="#directionsModal" onClick= "directionsModal();">Directions?</a></li>
              <li class="dropdown">
                      <!--<a id="drop1" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">Locate <b class="caret"></b></a>
                      <ul class="dropdown-menu" role="menu" aria-labelledby="drop1">
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="http://google.com">Building</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#anotherAction">Parking Lots/Structures</a></li>
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="#">Campus Entrances</a></li>
                      </ul>
                    </li>-->
              <!--<li><a href="urlGenerator.cfm">URL Gen</a></li>-->
              <li><a href="maps17-test1-click_street_view/default.cfm">StreetView</a></li>
              <li><a href="maps21-overlaytest3/default.cfm">Overlay</a></li>
                  </ul>
                </li>
              </ul>
            </div><!--/.nav-collapse -->
          </div><!-- /.navbar-inner -->
        </div><!-- /.navbar -->

      </div> <!-- /.container -->
    </div><!-- /.navbar-wrapper --> 
   <div class="container">

	  <!---<div id="directions-panel"></div>--->
      <!--Map Div
      ==================================================================================-->
      <div id="mapCanvas"></div>
      
      <!--Modals defined here
      ==================================================================================-->
      <!-- Stall Inventory Modal -->
      <div id="StallInventoryModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">X</button>
        <h3>Stall Info</h3>
        </div>
        <div class="modal-body">
        <div id="StallInventoryModalInfo"></div>
        </div>
        <div class="modal-footer">
        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        </div>
      </div>
      
      <!-- where to park Modal -->
      <div id="whereToParkModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">X</button>
        <h3 id="myModalLabel">Where To Park</h3>
        </div>
        <div class="modal-body"> 
        <center><p>Select your affiliation:</p></center>
        
        <!---Buttons to choose who you are --->
        <div class="controls">
        	<center>
        	<button id="Visitor" name="Visitor" class="btn-large btn-primary" onClick ="changeVisitorType(1);">Visitor</button>
    		<button id="Student" name="Student" class="btn-large btn-primary" onClick ="changeVisitorType(2);">Student</button>
            <button id="Staff" name="Staff" class="btn-large btn-primary" onClick ="changeVisitorType(3);">Staff</button>
            <button id="Vendor/Service Permits" name="Vendor/Service Permits" class="btn-large btn-primary" onClick ="changeVisitorType(4);">Vendor/Service Permits</button>
            </center>
  		</div>
        </div>
        <div class="modal-footer">
        <button class="btn btn-primary">Next</button>
        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        </div>
      </div>
      
      <!-- Where to park - Visitor Modal -->
      
      <style type="text/css"> .modal-backdrop {background: none;} </style>
      <!--<style type="text/css"> .modal.fade.in {width: 300px; margin: -15px 0 0 -150px; /* PLAY THE WITH THE VALUES TO SEE GET THE DESIRED EFFECT */}</style>-->
      <div id="whereToParkModalInfo" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>You Can Park Here</h3>
        </div>
        <div class="modal-body">
        	<div id="WhereToParkModalInfo">
            	<div id="WhereToParkModalInfo-List">
            	</div>
        	</div>
        </div>
        <div class="modal-footer">
        <a href="#" class="btn">Close</a>
        <a href="#" class="btn btn-primary">Save changes</a>
        </div>
      </div>
         
      <!-- Directions Modal -->
      <div id="directionsModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">X</button>
        <h3 id="myModalLabel">Directions</h3>
        </div>
        <div class="modal-body">
        <div>
        <strong>Start: </strong>
        <select id="start" onchange="calcRoute();">
          <option value="chicago, il">Chicago</option>
          <option value="st louis, mo">St Louis</option>
          <option value="joplin, mo">Joplin, MO</option>
          <option value="oklahoma city, ok">Oklahoma City</option>
          <option value="amarillo, tx">Amarillo</option>
          <option value="gallup, nm">Gallup, NM</option>
          <option value="flagstaff, az">Flagstaff, AZ</option>
          <option value="winona, az">Winona</option>
          <option value="kingman, az">Kingman</option>
          <option value="barstow, ca">Barstow</option>
          <option value="san bernardino, ca">San Bernardino</option>
          <option value="los angeles, ca">Los Angeles</option>
        </select>
        <strong>End: </strong>
        <select id="end" onchange="calcRoute();">
          <option value="chicago, il">Chicago</option>
          <option value="st louis, mo">St Louis</option>
          <option value="joplin, mo">Joplin, MO</option>
          <option value="oklahoma city, ok">Oklahoma City</option>
          <option value="amarillo, tx">Amarillo</option>
          <option value="gallup, nm">Gallup, NM</option>
          <option value="flagstaff, az">Flagstaff, AZ</option>
          <option value="winona, az">Winona</option>
          <option value="kingman, az">Kingman</option>
          <option value="barstow, ca">Barstow</option>
          <option value="san bernardino, ca">San Bernardino</option>
          <option value="los angeles, ca">Los Angeles</option>
        </select>
        </div>
        </div>
        <div class="modal-footer">
        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        </div>
      </div>
      
      
      <div id="directionsFromGoogleModal" class="modal hide" tabindex="-1" role="dialog" aria-labelledby="directionsFromGoogleModal" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Modal header</h3>
        </div>
        <div class="modal-body">
        <div id="directions-panel">gfhysdkgdfhjkagshfjkahkfhdajkghdasg</div>
        </div>
        <div class="modal-footer">
        <a href="#" class="btn">Close</a>
        <a href="#" class="btn btn-primary">Save changes</a>
        </div>
      </div>
      
      <div id="directions-panel">gfhysdkgdfhjkagshfjkahkfhdajkghdasg</div>
      
      <div id="accessabilityModal" class="modal hide" tabindex="-1" role="dialog" aria-labelledby="accessabilityModal" aria-hidden="true">
        <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Modal header</h3>
        </div>
        <div class="modal-body">
        <div id="ADAModalInfo"></div>
        </div>
        <div class="modal-footer">
        <a href="#" class="btn">Close</a>
        <a href="#" class="btn btn-primary">Save changes</a>
        </div>
      </div>

    </div> <!-- /container -->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="assets/js/jquery.js"></script>
    <script src="assets/js/bootstrap/bootstrap-transition.js"></script>
    <script src="assets/js/bootstrap/bootstrap-alert.js"></script>
    <script src="assets/js/bootstrap/bootstrap-modal.js"></script>
    <script src="assets/js/bootstrap/bootstrap-dropdown.js"></script>
    <script src="assets/js/bootstrap/bootstrap-scrollspy.js"></script>
    <script src="assets/js/bootstrap/bootstrap-tab.js"></script>
    <script src="assets/js/bootstrap/bootstrap-tooltip.js"></script>
    <script src="assets/js/bootstrap/bootstrap-popover.js"></script>
    <script src="assets/js/bootstrap/bootstrap-button.js"></script>
    <script src="assets/js/bootstrap/bootstrap-collapse.js"></script>
    <script src="assets/js/bootstrap/bootstrap-carousel.js"></script>
    <script src="assets/js/bootstrap/bootstrap-typeahead.js"></script>
    
    <script type="text/javascript">
    		$(document).ready(function(){
				alert('This is a prototype of an interactive parking map. This does not in any way represent a production ready experience.');
			});
    </script>

  </body>
</html>
