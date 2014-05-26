<cfcomponent bindingname="map">

<cfset db1 = "ANTPARK">
<cfset db2 = "EPICS"> 

<cffunction
		name="dbConnectionTest"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <!--- Check to see if datasources are available. If not, stop loading the rest of the page --->
                <cftry>
                    <cfquery name="db1Check" datasource="#db1#">
                        SELECT TOP 1 * FROM tblPermitInfo
                    </cfquery>
                    <cfquery name="db2Check" datasource="#db2#">
                        SELECT TOP 1 * FROM kiosk_status
                    </cfquery>
                <cfcatch type="any">
                    <center>
                        <p>We are currently experiencing some technical difficulties with the Interactive Map. Please check back in a few minutes.</p>
                    </center>
                    <cfinclude template="/templates/footer.cfm">
                    <cfabort>
                </cfcatch>
                </cftry>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>

<!---Functions for converting data to xml
==========================================================================================================================--->
<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML">
	<cfargument name="data" type="array" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var x = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfloop index="x" from="1" to="#arrayLen(arguments.data)#">
		<cfset s = s & "<" & arguments.itemelement & ">" & xmlFormat(arguments.data[x]) & "</" & arguments.itemelement & ">">
	</cfloop>
	
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>
</cffunction>

<cffunction name="listToXML" returnType="string" access="public" output="false" hint="Converts a list into XML.">
	<cfargument name="data" type="string" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="delimiter" type="string" required="false" default=",">
	
	<cfreturn arrayToXML( listToArray(arguments.data, arguments.delimiter), arguments.rootelement, arguments.itemelement)>
</cffunction>

<cffunction name="queryToXML" returnType="string" access="public" output="false" hint="Converts a query to XML">
	<cfargument name="data" type="query" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="cDataCols" type="string" required="false" default="">
	
	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var col = "">
	<cfset var columns = arguments.data.columnlist>
	<cfset var txt = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfloop query="arguments.data">
		<cfset s = s & "<" & arguments.itemelement & ">">

		<cfloop index="col" list="#columns#">
			<cfset txt = arguments.data[col][currentRow]>
			<cfif isSimpleValue(txt)>
				<cfif listFindNoCase(arguments.cDataCols, col)>
					<cfset txt = "<![CDATA[" & txt & "]]" & ">">
				<cfelse>
					<cfset txt = xmlFormat(txt)>
				</cfif>
			<cfelse>
				<cfset txt = "">
			</cfif>

			<cfset s = s & "<" & col & ">" & txt & "</" & col & ">">

		</cfloop>
		
		<cfset s = s & "</" & arguments.itemelement & ">">
	</cfloop>
	
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>
</cffunction>

<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML.">
	<cfargument name="data" type="struct" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">

	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var keys = structKeyList(arguments.data)>
	<cfset var key = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfset s = s & "<" & arguments.itemelement & ">">

	<cfloop index="key" list="#keys#">
		<cfset s = s & "<#key#>#xmlFormat(arguments.data[key])#</#key#>">
	</cfloop>
	
	<cfset s = s & "</" & arguments.itemelement & ">">
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>		
</cffunction>

<!---Creating the needed xml files and checking to make sure they dont exist
===========================================================================================================================--->
<cffunction
		name="createAllLots"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/allLots.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        <cfquery name="allLots" datasource="#db1#">
                    SELECT *
                    FROM tblCampusLots
                    WHERE disabled = 0 AND lot_name NOT LIKE 'Service%'
                    ORDER BY displayOrder
        </cfquery>
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(allLots, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/allLots.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>

<cffunction
		name="createAllBuildings"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/allBuildings.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        <cfquery name="buildingInfo" datasource="#db1#">
                    SELECT * FROM tblBuildingData
                    ORDER BY building_name
                </cfquery>
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(buildingInfo, "buildings", "building")>
        <cffile action="write" file="#expandpath('assets/xml/allBuildings.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>

<cffunction
		name="createKiosks"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/kiosks.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        <cfquery name="kioskMarkers" datasource="#db1#">
                    SELECT id, lot_id, misc_id, kiosk_id, latitude, longitude, description FROM tblCampusMiscInLots WHERE kiosk_id IS NOT null 
                </cfquery>
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(kioskMarkers, "kiosks", "kiosk")>
        <cffile action="write" file="#expandpath('assets/xml/kiosks.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>

<cffunction
		name="createPermitDisp"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/permitDisp.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        <cfquery name="kioskMarkers" datasource="#db1#">
                    SELECT id, lot_id, misc_id, kiosk_id, latitude, longitude, description FROM tblCampusMiscInLots WHERE kiosk_id IS NOT null 
                </cfquery>
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(kioskMarkers, "dispensers", "dispenser")>
        <cffile action="write" file="#expandpath('assets/xml/permitDisp.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>

<cffunction
		name="createVisitorParking"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/VisitorParking.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        <cfquery name="visitor_p" dbtype="query">
                    SELECT *
                    FROM getPermitsAndGroups
                    WHERE categoryName = 'VISITOR'
                </cfquery>
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(visitor_p, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/VisitorParking.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">--->       
</cffunction>
    


<cffunction
		name="createZotWheelsXML"
		access="public"
		output="yes"
        returntype = "struct"
		hint="Creates the xml files needed to place markers on the map">
        
        <cfset createxml = 0>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/zotWheels.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <!--- ZOTWHEELS RACK --->
        <cftry>
        
        <cfinvoke webservice="http://shire.pts.uci.edu/RFIDWebService.asmx?WSDL" method="RackStatus" returnvariable="ZWheelsRackStatus">
        
        </cfinvoke>
        <cfset wurl="http://shire.pts.uci.edu/RFIDWebService.asmx?WSDL">
        <cfset ws = createObject("webservice", wurl)>
        <cfset req = getSoapRequest(ws)>
        <cfset response = GetSOAPResponse(ws)>
        
        <cfset thexmldoc = xmlparse(response)>
        <cfset xmlLocations = XmlSearch(thexmldoc,"//*[name()='locations']") />
        <cfoutput>
            <cfloop from="1" to="#xmlLocations.size()#" index="i">
                <cfset "rack#i#" = StructNew()>
                <cfloop from="1" to="#xmllocations[i].xmlChildren.size()#" index="j">
                    <cfoutput>
                        <cfset "rack#i#.#xmllocations[i].xmlChildren[j].xmlName#" = #xmllocations[i].xmlChildren[j].xmltext#>
                        <!---#xmllocations[i].xmlChildren[j].xmlName#: #xmllocations[i].xmlChildren[j].xmltext# <br />--->
                    </cfoutput>
                </cfloop>
            </cfloop>
        </cfoutput>
        
        <cfset toXML = createObject("component", "map")>
        <cfset xmlStruct1 = toXML.structToXML(rack1, "wheels", "wheel")>
        <cfset xmlStruct2 = toXML.structToXML(rack2, "wheels", "wheel")>
        <cfset xmlStruct3 = toXML.structToXML(rack3, "wheels", "wheel")>
        <cfset xmlStruct4 = toXML.structToXML(rack4, "wheels", "wheel")>
		<!---<cfdump var="#xmlParse(xmlStruct)#">--->
        <cfcatch>
        <cfset createxml = 0>
        </cfcatch>
        </cftry>
        
        <cfif createxml eq 1>
        <cffile action="write" file="#expandpath('assets/xml/zotWheels1.xml')#" output="#xmlStruct1#" />
        <cffile action="write" file="#expandpath('assets/xml/zotWheels2.xml')#" output="#xmlStruct2#" />
        <cffile action="write" file="#expandpath('assets/xml/zotWheels3.xml')#" output="#xmlStruct3#" />
        <cffile action="write" file="#expandpath('assets/xml/zotWheels4.xml')#" output="#xmlStruct4#" />
        </cfif>
        
        <!--- Define empty zotwheels info if unable to retrieve details --->
        <cfparam name="rack1" default="">
        <cfparam name="rack2" default="">
        <cfparam name="rack3" default="">
        <cfparam name="rack4" default="">
        
        <cfreturn rack3>
        
</cffunction>

<!---Always create these next few xmls, they are needed for where to park also--->
<cffunction
		name="alwaysCreateXML"
		access="public"
		returntype="void"
		output="true"
		hint="Creates the xml files needed for the where to park info modal">
        
        <cfset createxml = 0>
        <cfquery name="getPermitsAndGroups" datasource="#db1#">
    	SELECT DISTINCT 'P' AS permitOrGroup, i.id, i.type, i.description, i.display_category AS categoryId, c.category AS categoryName
    	FROM tblPermitInfo i INNER JOIN tblPermitCategories c ON i.display_category = c.id 
    	UNION
    	SELECT DISTINCT 'G' AS permitOrGroup, g.id, '' AS type, g.name AS description, g.display_category AS categoryId, c.category AS categoryName
    	FROM tblPermitGroups g INNER JOIN tblPermitCategories c ON g.display_category = c.id
    	WHERE g.disabled = 0
		</cfquery>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/student_p.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        
        <cfquery name="student_p" dbtype="query">
    		SELECT *
    		FROM getPermitsAndGroups
    		WHERE categoryName = 'STUDENT' OR categoryName = 'STUEMP'
		</cfquery>
        
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery = toXML.queryToXML(student_p, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/student_p.xml')#" output="#xmlQuery#" />
        </cfif>
        
        <!---<cfdump var="#createxml#">---> 
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/visitor_p.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        
        <cfquery name="visitor_p" dbtype="query">
            SELECT *
            FROM getPermitsAndGroups
            WHERE categoryName = 'VISITOR'
        </cfquery> 
        
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery1 = toXML.queryToXML(visitor_p, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/visitor_p.xml')#" output="#xmlQuery1#" />
        </cfif>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/staff_p.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        
        <cfquery name="staff_p" dbtype="query">
            SELECT *
            FROM getPermitsAndGroups
            WHERE categoryName = 'STAFF' OR categoryName = 'STUEMP'
        </cfquery>
        
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery1 = toXML.queryToXML(staff_p, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/staff_p.xml')#" output="#xmlQuery1#" />
        </cfif>
        
        <!---Check to see if file exists.--->
		<cfif FileExists(#ExpandPath('assets/xml/service_p.xml')#)>
        	<!---Check the date last modified, if older than day, recreate--->
        	<cfset filePath = ExpandPath('assets/xml/allLots.xml')>
        	<cfset fileObj = createObject("java","java.io.File").init(filePath)>
        	<cfset fileDate = createObject("java","java.util.Date").init(fileObj.lastModified())>
        	<cfset today = now() >
        	<cfif DateCompare(filedate,today,"d") is not 0>
            <cfset createxml = 1>
            </cfif>
        <cfelse>
        <cfset createxml = 1>
        </cfif>
        
        <cfif createxml eq 1>
        
        <cfquery name="service_p" dbtype="query">
            SELECT *
            FROM getPermitsAndGroups
            WHERE categoryName = 'SERVICE'
        </cfquery>
        
        <cfset toXML = createObject("component", "map")>
        <cfset xmlQuery1 = toXML.queryToXML(service_p, "lots", "lot")>
        <cffile action="write" file="#expandpath('assets/xml/service_p.xml')#" output="#xmlQuery1#" />
        </cfif>
              
</cffunction>

<!--- ADA INFO AJAX CALL ( getADAInfo() ) --->
<cffunction 
		name="getADAInfo" 
        hint="gets ada info and then returns the info to be displayed on the browser through a response" 
        returntype="struct" 
        access="remote">
    <cfargument name="buildingNumber" type="string" required="yes" displayname="buildingNumber">
    
	<cfset buildingInfo = structNew()>    
	<cfset buildingNumber = #REReplace("#buildingNumber#", "[^0-9]", "", "ALL")#>
	
	<cfif isNumeric(buildingNumber) AND buildingNumber NEQ 0>
    	<cftry>
            <cfquery name="ADAInfo" datasource="#db1#">
                SELECT * 
                FROM tblADAData
                WHERE building_id = '#buildingNumber#'
            </cfquery>
            
            <cfif ADAInfo.recordcount GT 0>
				<cfset buildingInfo.lot_id = ADAInfo.lot_id>
                <cfset buildingInfo.distance = ADAInfo.distance>
                <cfset buildingInfo.main_entrance = ADAInfo.main_entrance>
                <cfset buildingInfo.rear_entrance = ADAInfo.rear_entrance>
                <cfset buildingInfo.elevator = ADAInfo.elevator>
                <cfset buildingInfo.ramps = ADAInfo.ramps>
                <cfset buildingInfo.closest_lot_1 = ADAInfo.closest_lot_1>
                <cfset buildingInfo.closest_lot_2 = ADAInfo.closest_lot_2>
                <cfset buildingInfo.total_d_stalls_1 = ADAInfo.total_d_stalls_1>
                <cfset buildingInfo.total_d_stalls_2 = ADAInfo.total_d_stalls_2>
                <cfset buildingInfo.notes = ADAInfo.special_notes> 
           </cfif>
        
        	<cfcatch type="any">
            	<cfset buildingInfo = structNew()>  
            </cfcatch>
        </cftry>

    </cfif> 
   
    <cfreturn buildingInfo>    
</cffunction>

<!--- populate "stalls_in_lot" table --->
<cffunction name="getLotInfo" returntype="query" access="remote">
    <cfargument name="lot_id" type="string" required="yes" displayname="lot_id">
	
    <cfset lot_id = #REReplace("#lot_id#", "[^0-9]", "", "ALL")#>
	
	<cfif isNumeric(lot_id) AND lot_id NEQ 0>
    	
        <cftry>
            <cfquery name="joinLotInfoWithLastMod" datasource="#db1#">
               SELECT tblCampusLots.lot_name, tblCampusLots.id AS lot_id, tblCampusStallsInLotInventory.stall_id, tblCampusStalls.common_name, tblCampusStallsInLotInventory.quantity, tblCampusStallsInLot.start_date AS lastmoddate
               FROM ((tblCampusLots INNER JOIN tblCampusStallsInLot ON tblCampusLots.ID = tblCampusStallsInLot.Lot_ID) INNER JOIN tblCampusStallsInLotInventory ON tblCampusStallsInLot.id = tblCampusStallsInLotInventory.inventory_id) INNER JOIN tblCampusStalls ON tblCampusStallsInLotInventory.stall_id = tblCampusStalls.id
               WHERE tblCampusLots.id = #lot_id# AND (tblCampusStallsInLot.deleted IS null OR tblCampusStallsInLot.deleted = 0) AND tblCampusStallsInLot.end_date IS null
            </cfquery>
            
            <cfcatch type="any">
            	<cfset joinLotInfoWithLastMod = queryNew("lot_name, lot_id, stall_id, common_name, quantity, start_date", "VarChar, Integer, Integer, VarChar, Integer, Date")>
            </cfcatch>
        </cftry>
    
    <cfelse>
        <cfset joinLotInfoWithLastMod = queryNew("lot_name, lot_id, stall_id, common_name, quantity, start_date", "VarChar, Integer, Integer, VarChar, Integer, Date")>
    </cfif> 

    <cfreturn joinLotInfoWithLastMod>
      
</cffunction>

<!---get permitted parking --->
<cffunction name="getAllowedParking" returntype="query" access="remote">

	<cfargument name="permitOrGroup" type="string" required="yes" displayname="permitOrGroup">
    <cfargument name="permitId" type="string" required="yes" displayname="permitId">

	<cfif NOT ((permitOrGroup EQ 'G' OR permitOrGroup EQ 'P') AND isNumeric(permitId))>
    	<cfreturn null>
    </cfif>

	<cfif permitOrGroup EQ 'P'>
    	
        <cftry>
            <cfquery name="getLots" datasource="#db1#">
                SELECT DISTINCT l.* 
                FROM tblValidLots v, tblCampusLots l, tblCampusLotsInGroup g 
                WHERE v.permit_id = #permitId#
                AND ((v.lot_id = l.id) OR (v.lotgroup_id = g.group_id AND l.id = g.lot_id)) AND l.displayOrder <> 0
                UNION
                SELECT DISTINCT l.*
                FROM tblValidLots v, tblCampusLots l, tblPermitsInGroup pg, tblCampusLotsInGroup g
                WHERE pg.permit_id = #permitId# AND pg.group_id = v.permitgroup_id
                AND ((v.lot_id = l.id) OR (v.lotgroup_id = g.group_id AND l.id = g.lot_id)) AND l.displayOrder <> 0
                ORDER BY l.displayOrder
            </cfquery>  
   		
        	<cfcatch type="any">
            	<cfset getLots = QueryNew("id, lot_num, lot_name, latitude, longitude, disabled, displayOrder", "Integer, VarChar, VarChar, VarChar, Bit, Integer")>
            </cfcatch>
		</cftry>
   
    <cfelse>
    
    	<cftry>
            <cfquery name="getLots" datasource="#db1#">
                SELECT DISTINCT l.* 
                FROM tblValidLots v, tblCampusLots l, tblCampusLotsInGroup g 
                WHERE v.permitgroup_id = #permitId#
                AND ((v.lot_id = l.id) OR (v.lotgroup_id = g.group_id AND l.id = g.lot_id)) AND l.displayOrder <> 0
                ORDER BY l.displayOrder
            </cfquery>  
			
            <cfcatch type="any">
            	<cfset getLots = QueryNew("id, lot_num, lot_name, latitude, longitude, disabled, displayOrder", "Integer, VarChar, VarChar, VarChar, Bit, Integer")>
            </cfcatch>
		</cftry>   
   
    </cfif> 

    <cfreturn getLots>
      
</cffunction>

</cfcomponent>