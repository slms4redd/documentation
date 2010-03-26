<%
/*
 *  GeoBatch - Open Source geospatial batch processing system
 *  http://geobatch.codehaus.org/
 *  Copyright (C) 2007-2008-2009 GeoSolutions S.A.S.
 *  http://www.geo-solutions.it
 *
 *  GPLv3 + Classpath exception
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
%>
<%@ page contentType="text/html" import="java.sql.*, java.io.*, java.util.*, it.geosolutions.geobatch.catalog.*, it.geosolutions.geobatch.flow.event.action.*, it.geosolutions.geobatch.flow.event.listeners.status.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<title wicket:id="pageTitle">GeoBatch</title>
      <link href="img/favicon.ico" rel="shortcut icon"/>
      <link rel="stylesheet" href="css/blueprint/screen.css" type="text/css" media="screen, projection" />
      <link rel="stylesheet" href="css/blueprint/print.css" type="text/css" media="print" />
	  <link rel="stylesheet" href="css/app.css" type="text/css" media="screen, projection" />
	  <link rel="stylesheet" href="css/jpaginate.css" type="text/css" media="screen, projection" />
	  
	<link type="text/css" href="css/ui-lightness/jquery-ui-1.8.custom.css" rel="stylesheet" />	
	<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui-1.8.custom.min.js"></script>
	<script type="text/javascript" src="js/jquery.paginate.js"></script>
	
	<script type="text/javascript">
		$(function(){
			// Accordion
			$("#accordion2").accordion({
				active: false,
				header: "h3",
				collapsible: true,
				autoHeight: false,
				alwaysOpen: false,
				animated: true,
				showSpeed: 400,
				hideSpeed: 800
			});
			
			// Dialogs
			$("a.actions").click(
				function() {
					var url = this.href;
					var dialog = $("#dialog-modal").get(0);
	
					if (dialog != null || dialog != "undefined") {
						$("#dialog-modal").remove();
						dialog = null;
					}
	
					dialog = $('<div id="dialog-modal" style="display:hidden"></div>');
					
	               	// load remote content
	               	dialog.load(
	                       url, 
	                       {},
	                       function (responseText, textStatus, XMLHttpRequest) {
	                       	dialog.dialog({
	                           	title: 'Instance actions...',
	                           	width: 600,
	                   			height: 700,
	                   			modal: true
	                   		});
	
	                       }
	               );
	
	               //prevent the browser to follow the link
	               return false;
	       	});
	
			
		});
	</script>
</head>
<body>
	<c:set var="fm" value="${flowManager}"/>

	<!-- Accordion -->
	<div id="accordion2">
		<c:forEach var="ec" items="${fm.eventConsumers}">
		    <h3>
		    	<a href="#">
			    	<c:out value="${ec.id}"/>
				</a>
		    </h3>
		    <div>
			    <UL>
				    <LI> - <B>status</B>:
				    	<c:choose> 
							<c:when test="${ec.status == 'FAILED'}">
								<font style="font-style: italic; font-weight: bold; font-size: 12px; color: red">
							</c:when>
							<c:otherwise>
								<font style="font-style: italic; font-weight: bold; font-size: 12px; color: green">
							</c:otherwise>
						</c:choose>
				    	<c:out value="${ec.status}"/></font>
							<c:choose>
						        <c:when test="${ec.paused}">
						            <a href='consumerResume.do?fmId=${fm.id}&ecId=${ec.id}'><image src='img/control_play.png' border='0' title='resume instance' alt='resume' width='16' height='16'/></a>
						    		<a href="consumerDispose.do?fmId=${fm.id}&ecId=${ec.id}"><image src='img/cancel.png' border='0' title='cancel instance' alt='cancel' width='16' height='16'/></a>
						        </c:when>
						        <c:otherwise>
						            <a href='consumerPause.do?fmId=${fm.id}&ecId=${ec.id}'><image src='img/control_pause.png' border='0' title='pause instance' alt='pause' width='16' height='16'/></a>
						        </c:otherwise>
						    </c:choose>
						    <a class="actions" href="consumerInfo.do?fmId=${fm.id}&ecId=${ec.id}"><image src='img/page_white_text.png' border='0' title='instance logs' alt='logs' width='16' height='16'/></a>
				    </LI>
				    <LI> - <B>created</B>: <fmt:formatDate value="${ec.creationTimestamp.time}" type="both" dateStyle="SHORT" timeStyle="FULL"/></LI>
				    <LI> - <B>consumer info</B>: <c:out value="${ec}"/><br/></LI>
			    </UL>
			    <font style="font-style: italic; font-weight: bold; font-size: 12px; color: blue">Flow Start</font> -->&nbsp;
			    <c:forEach var="ac" items="${ec.actions}">
			    	<c:set var="action" value="${ac}" scope="request" />
			    	<% 
			    		request.setAttribute("acStatus", ((BaseAction)request.getAttribute("action")).getProgressListener(StatusProgressListener.class));
			    	%>
			    	<c:choose> 
						<c:when test="${acStatus != null}">
					    	<c:choose>
								<c:when test="${acStatus.failed}">
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: red">
								</c:when>
								<c:when test="${acStatus.terminated}">
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: orange">
								</c:when>
								<c:when test="${acStatus.completed}">
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: green">
								</c:when>
								<c:when test="${acStatus.paused}">
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: blue">
								</c:when>
								<c:when test="${acStatus.started}">
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: yellow">
								</c:when>
								<c:otherwise>
									<font style="font-style: italic; font-weight: bold; font-size: 12px; color: black">
								</c:otherwise>
							</c:choose>
							<c:out value="${ac.class.simpleName}"/></font>
					    	<c:choose>
								<c:when test="${acStatus.failed}">
									<font style="font-style: italic; font-size: 12px; color: black">(${acStatus.failException.message})</font>
								</c:when>
								<c:otherwise></c:otherwise>
							</c:choose>
						</c:when>
						<c:otherwise>
							<c:out value="${ac.class.simpleName}"/> <font style="font-style: italic; font-size: 12px; color: black">(No status info)</font>
						</c:otherwise>
					</c:choose>
					&nbsp;-->&nbsp;			    	
			    </c:forEach>
			    <font style="font-style: italic; font-weight: bold; font-size: 12px; color: blue">Flow End</font>
		    </div>
		</c:forEach>
	</div>
</body>