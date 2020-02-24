/** save the content of the preview frame to the server */
function saveContentToServer(content, vendorid, siteid, pageid, titletext) 
{
	$.ajax(
		{
			url: 'save_page',
			type: 'POST',
			datatype: 'application/json',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
			},
			proccessData: 'false',
			data: 
			{
				'frame_content': content,
				'vendor_id': vendorid,
				'site_id': siteid,
				'page_id': pageid,
				'title': titletext
			}, 
			success: function(data) 
			{
				console.log("Page saved");
				alert('Page saved.');
				refreshPageListPreview();
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("ERROR: " + strError + " " + errorThrown);
			}
		});
}
/** save the content of the local storage element to the server */
function saveAllPagesToServer(content, vendorid, siteid, pageid, titletext) 
{
	$.ajax(
		{
			url: 'save_page',
			type: 'POST',
			datatype: 'application/json',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
			},
			proccessData: 'false',
			data: 
			{
				'frame_content': content,
				'vendor_id': vendorid,
				'site_id': siteid,
				'page_id': pageid,
				'title': titletext
			}, 
			//if saved succesfully refreshes all page iframes and displayes an alert
			success: function(data) 
			{
				pageChanges[pageid] = false;
				document.getElementById("pageList"+pageid).contentWindow.location.reload(true);
				if(!hasUnsavedChanges())
				{
					console.log("All pages have been saved.");
					alert('All pages have been saved.');
				}
				restoreOriginalStateToStorage(pageid);
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("ERROR: " + strError + " " + errorThrown);
			}
		});
}

// save current page selection as default landing page
function setAsDefaultLandingPage(siteid, pageid) {
	setLandingPageId(pageid);
	$.ajax(
		{
			url: 'set_landing',
			type: 'POST',
			datatype: 'application/json',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
			},
			proccessData: 'false',
			data: 
			{
				'site_id': siteid,
				'page_id': pageid
			}, 
			success: function(data) 
			{
				if (landingPageId != "") {
					alert('Page set as default landing page.');
				}
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("ERROR: " + strError + " " + errorThrown);
			}
		});
}

/** Delete an existing page */
function deletePage(vendorid, landingpage, siteid, pageid) 
{
	localStorage.removeItem('page'+pageid);
	if (pageid == landingpage) {
		setLandingPage(0);
	}
	
	delete pageChanges['page'+pageid];
	delete pageLoaded['page'+pageid];
	
	/** delete the page from the database and from the server */
	$.ajax(
		{
			url: 'destroy',
			datatype: 'application/json',
			type: 'POST',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name  = "csrf-token"]').attr('content'))
			},
			data: 
			{
				vendor_id: 	vendorid,
				site_id: 	siteid, 
				page_id:	pageid
			}, 
			success: function(data) 
			{
				/** remove it from the view */
				$("#pageholder" + pageid).remove();
				/** clear the current preview */
				$("#preview_frame").contents().find('html').empty();
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("Error: " + strError + " " + errorThrown);
			}
		});
}

/** send site_id and vendor_id of the frame for manipulation */
function downloadAllContent(vendorid, siteid) {
	/** zip all the files in sites/vendor_id/site_id/ folder and send them back to the browser */
	$.ajax({
		url : 'export_all',
		type : 'POST',
		datatype : 'application/html',
		beforeSend : function(xhr) {
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
		},
		data : {
			'vendor_id' : vendorid,
			'site_id' : siteid
		},
		error : function(objAJAXRequest, strError, errorThrown) {
			alert("Error: " + strError + " " + errorThrown);
		}
	});
}

// ajax function to update descriptions
// activates onchange for each individiual description field
// same as in the textfields of the contents tab
function setNewDesc(IdOfDesc, IdOfPic) {
	// Arguments:
	// IdOfDesc -- generated using unique id of resource from db
	// IdOfPic -- unique id of resource from db
	// fetch description with jquery
	desc = $("#" + IdOfDesc).val();
	$.ajax(
	{
		url: 'update_desc',
		type: 'POST',
		datatype: 'application/json',
		beforeSend : function(xhr)
		{
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
		},
		proccessData: 'false',
		data: 
		{
			'id': IdOfPic,
			'desc': desc
		}, 
		success: function(data) 
		{
			// refresh content tab image lists TODO
		},
		error: function(objAJAXRequest, strError, errorThrown) 
		{
			alert("ERROR: " + strError + " " + errorThrown);
		}
	});
}

// refresh the pages list when content tab is clicked, synchronous
function refreshPagesList(siteid) {
	var result =""; 
	$.ajax({
			url: 'refresh_pages_list',
			async: false, // wait for the response
			type: 'POST',
			datatype: 'application/json',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
			},
			proccessData: 'false',
			data: 
			{
				'site_id': siteid
			}, 
			success: function(data) 
			{
				result = data;
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("ERROR: " + strError + " " + errorThrown);
			}
		});
	return result;
}
// refresh the resources list when content tab is clicked, synchronous
function refreshResourcesList(siteid) {
	var result =""; 
	$.ajax({
			url: 'refresh_resources_list',
			async: false, // wait for the response
			type: 'POST',
			datatype: 'application/json',
			beforeSend : function(xhr)
			{
				xhr.setRequestHeader('X-CSRF-Token', $('meta[name = "csrf-token"]').attr('content'))
			},
			proccessData: 'false',
			data: 
			{
				'site_id': siteid
			}, 
			success: function(data) 
			{
				result = data;
			}, 
			error: function(objAJAXRequest, strError, errorThrown) 
			{
				alert("ERROR: " + strError + " " + errorThrown);
			}
		});
	return result;
}
