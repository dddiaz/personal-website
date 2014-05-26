<!--- Set up the application. --->
	<cfapplication name = "map"
			sessionmanagement = "true"
			setclientcookies = "true"
            sessiontimeout="#CreateTimeSpan(0,0,30,0)#" >