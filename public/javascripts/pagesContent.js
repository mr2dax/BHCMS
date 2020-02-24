//data for current page - the vendor id 
var vendorid;
//the site id
var siteid;
/**the resources for the site - array with images
 * format is galleryImages = Array[0: 621, 1: "IMG DESCR", 2: "jpg", 3: 622, 4: "IMG DESCR2", 5: "jpg"...*/
var galleryImages;
var IMGS_ARRAY_DIMENSIONS = 3;
var IMGS_FILE_NAME_OFFSET = 0;
var IMGS_DESCRIPTION_OFFSET = 1;
var IMGS_FILE_EXTENS_OFFSET = 2; 

/** the pages for the site - array with page titles
 	format is pages = Array[0: 12, 1: "Title of page 12", 2: 42, "Title of page 42",...] */
var pages;
var PAGES_ARRAY_DIMENSIONS = 2;
var PAGES_ID_OFFSET = 0;
var PAGES_TITLE_OFFSET = 1;
					
//string constant used in constructing elements in the "Content" tab
var IMG_SRC_PREFIX	= "imgSrc";		//eg. id="imgSrcTitleImage" , "TitleImage" is an html element id
var ELEM_LNK_PREFIX	= "elemLink"; 	//eg. id="elemLinkTitleImage"

var DEF_IMAGE_PATH  = "/images/defaultImage.png"

//set the site data which is needed for the parsing of the content  
function setSiteData(vendor,site){
	vendorid 	= vendor;
	siteid 		= site;
	// get the most up-to-date pages list
	pages 		= refreshPagesList(siteid);
	// get the most up-to-date resources list
	galleryImages	= refreshResourcesList(siteid);
}

// split the string into an array by line separator
function multilineTrim(htmlString) {
   // call $.trim on each line
   // filter out the empty lines
   // join the array of lines back into a string
   return htmlString.split("\n").map($.trim).filter(function(line) { return line != "" }).join("\n");
}

//Function that displays all the editable fields in contents tab retrieved from the html document that is loaded in iframe 
function get_iframe() {
	//clears div content in content tab
	$("#content_tab").empty();
	var stringToAppend;
	var elementsCollected = 0;
	var numberOfEditables = $(htmlObject).find('.editable').length;
	//if there is no content prints out error message
	if (numberOfEditables == 0) {
		$("#content_tab").append(
			"<div style='color:red; width:100%;'>There is no content to display</div><br/>");
	}
	//loops through the document and finds elements with id=editable
	else
		$(htmlObject).find('.editable').each(function(index, element) {
			
			//if this is the beginning of a new item or appendable view - append 
			//whatever we have gathered and reset the string collecting item information
			if (($(this).attr("class").indexOf("_item") !== -1) || 	//this is an item
				 (!$(this).parents().hasClass('appendable'))){		//this is an element which is not part of an appendable group
				appendContentTab(stringToAppend, elementsCollected);
				stringToAppend = "";
				elementsCollected = 0;
			} 
			
			//if tagName is img makes a div for an image
			if ($(this).is("img")||$(this).is("canvas") ) {
				stringToAppend += generateImgDiv(this.id);
				elementsCollected++;
			}
			//if tagName is button makes a div for a button
			else if ($(this).is("button")) {
				stringToAppend += generateButtonDiv(this.id);
				elementsCollected++;
			}
			//if map  
			else if ($(this).attr('id') == "theMap") {
				stringToAppend += generateMapDiv(this.id);
				elementsCollected++;
			}
			//a list of items which can change their count
			else if ($(this).hasClass("appendable")) {
				stringToAppend += generateAppendableDiv(this.id);
			}
			// make an input for text (not appendable item)
			else if ($(this).attr("class").indexOf("_item") !== -1){
				stringToAppend += generateItemDiv(this.id);
			} else {
				stringToAppend += generateElementDiv(this);
				elementsCollected++;
			}
			
			//if we reached the end - append whatever elements we have gathered
			if (index == numberOfEditables-1){
				appendContentTab(stringToAppend, elementsCollected);
			}
		});
		//show options to assign link in all link select elements
		printLinkOptions();
		//show options to assign link in all picture select elements
		printPicOptions();
}

/** generate and return html code for a container to manuulate an image
 *  image id, remove image, image alt/title, image source and link */
function generateImgDiv(elementId){
	var objID = "text"+elementId;
	// get text, picture and page from preview frame to put in content tab's corresponding textfields and drop downs
	var content = $(htmlObject).find('#' + elementId).attr("title");
	var picture = $(htmlObject).find('#' + elementId).attr("src");
	return "<hr class='hr2'/>"+
			"<div style='width:100%;'>" + 
			//the id of the image
				"<span class='element_id'>"+BHCMSLABEL.element_id+"</span>" + 
				" <input id='"+objID+"' style='border:none; background: transparent; ' type='text' value='" + elementId + "' onchange='editId(&quot;"+objID+"&quot;,&quot;"+ elementId + "&quot;)'></input>  " +
				//button to remove the image
				"<button class='removeImage_button' type='button' id='"+elementId+"_remove' onclick='removeItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.removeImage_button+"</button><br/>" +
				//field to change the title of the image
				"<span class='alt_label'>"+BHCMSLABEL.alt_label+"</span>" + 
				"  <input id='"+objID+"_content' type='text' value='" + content + "' onchange='editAltAndTitle(&quot;"+objID+"_content&quot;,&quot;"+ elementId + "&quot;)'></input>  " +
				//menu to select link
				"<span class='link_label'>"+BHCMSLABEL.link_label+"</span>" +
				" <select id='" +ELEM_LNK_PREFIX + elementId + "' onchange='editLink(&quot;"+ elementId + "&quot;)'></select>"+
				//menu to select image 
				"<span class='image_label'>"+BHCMSLABEL.image_label+"</span>" +
				" <select id='" + IMG_SRC_PREFIX + elementId + "' onchange='editPicture(&quot;/sites/"+ vendorid +"/"+ siteid +"/res/&quot;,&quot;"+ elementId + "&quot;)'></select>  " +
			"</div>";
}

/** generate and return html code for a container to manuulate a button
 *  button id, remove button, button text, button link */
function generateButtonDiv(elementId){
	var objID = "button"+elementId;
	// get text and page from preview frame to put in content tab's corresponding textfields and drop downs
	var content = $(htmlObject).find('#' + elementId).text();
	return "<hr class='hr2'/>"+
			"<div style='width:100%; '>"+
				//the id of the button
				"<span class='element_id'>"+BHCMSLABEL.element_id+"</span>" + 
				" <input id='"+objID+"' style='border:none; background: transparent; ' type='text' value='" + elementId + "' onchange='editId(&quot;"+objID+"&quot;,&quot;"+ elementId + "&quot;)'></input>  " +
				//button to remove this button element
				"<button class='removeButton_button' type='button' id='"+elementId+"_remove' onclick='removeItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.removeButton_button+"</button><br/>" + 
				//field to change the text of the button
				"<span class='text_label'>"+BHCMSLABEL.text_label+"</span>" +
				" <input id='"+objID+"_content' type='text' value='" + content + "' onchange='editText(&quot;"+objID+"_content&quot;,&quot;"+ elementId + "&quot;)'></input>  " +
				//selector to pick link page
				"<span class='link_label'>"+BHCMSLABEL.link_label+"</span>" +
				" <select id='"+ELEM_LNK_PREFIX +elementId + "' onchange='editLink(&quot;"+ elementId + "&quot;)'></select>  "+
			"</div>";
}

/** generate and return html code for a container to manipulate a map
 *  mapa id, remove button, latitude, longitude, zoom options */
function generateMapDiv(elementId){
	var objID = "map_"+elementId;
	return "<hr class='hr2'/>"+
			"<div style='width:100%; '> Set the values for " + 
				//the id of the map
				"<span class='element_id'>"+BHCMSLABEL.element_id+"</span>" + 
				" <input id='"+objID+"' style='border:none; background: transparent; ' type='text' value='" + elementId + "' onchange='editId(&quot;"+objID+"&quot;,&quot;"+ elementId + "&quot;)'></input>  " +
				//button to remove the map
				"<button class='removeMap_button' type='button' id='"+elementId+"_remove' onclick='removeItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.removeMap_button+"</button><br/>" +
				//fields to edit the latitude, longitude and zoom 
				"<span class='latitude_label'>"+BHCMSLABEL.latitude_label+"</span>" + 
				" <input id='MapLaltitude' type='text' onchange='editMap()' value='"+ $(htmlObject).find('#latitude').val() +"'></input ><br/>  " +
				"<span class='longitude_label'>"+BHCMSLABEL.longitude_label+"</span>" + 
				" <input id='MapLongitude' type='text' onchange='editMap()' value='"+ $(htmlObject).find('#longitude').val() +"'></input ><br/>  " +
				"<span class='zoom_label'>"+BHCMSLABEL.zoom_label+"</span>" + 
				" <input style='width: 40%;' id='MapZoom' onchange='editMap()' type='range' min='6' max='20' Value = '"+$(htmlObject).find('#mapZoom').val()+"'>"+
			"</div>";
}

/** generate and return html code for a container with appendable children
 *  group id, remove group, add item */ 
function generateAppendableDiv(elementId){
	var objID = "append_"+elementId;
	return "<div style='width:100%; '>"+
				//the id of the element
				"<span class='elements_label'>"+BHCMSLABEL.elements_label+"</span>" + 
				" <input class='appendable_label' id='"+objID+"' style='border:none; background: transparent; ' type='text' value='" + elementId + "' onchange='editId(&quot;"+objID+"&quot;,&quot;"+ elementId + "&quot;)'></input>  " + 
				BHCMSLABEL.appendable_label + "  " +
				//button to add new elements
				"<button class='add_item_button' type='button' id='"+elementId+"_add' onclick='addAppendableItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.add_item_button+"</button>  " +
				//"<button type='button' id='"+elementId+"_remove' onclick='removeAppendableItem(&quot;"+elementId + "&quot);')>REMOVE ITEM</button>" +
				//button to remove this whole container
				"<button class='remove_items_button' type='button' id='"+elementId+"_remove' onclick='removeItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.remove_items_button+"</button>  " +
			"</div>";
}

/** generate and return html code for a container to manipulare an element inside an appendable item
 * element id, remove item, text, link */
function generateElementDiv(element){
	var objID = "text"+element.id;
	var content = $(htmlObject).find('#' + element.id).text();
	return  "<hr class='hr2'/>"+
			"<div style='width:100%; '>" + 
			//id of the element
				"<span class='element_id'>"+BHCMSLABEL.element_id+"</span>" + 
				" <input id='"+objID+"' style='border:none; background: transparent;' type='text' value='" + element.id + "' onchange='editId(&quot;"+objID+"&quot;,&quot;"+ element.id + "&quot;)'></input>  " +
				//button to remove the element
				"<button class='remove_element_button' type='button' id='"+element.id+"_remove' onclick='removeItem(&quot;"+element.id + "&quot);')>"+BHCMSLABEL.remove_element_button+"</button></br>" +
				//field to edit the content of the element 
				"<span class='text_label'>"+BHCMSLABEL.text_label+"</span>" +
				" <input id='"+objID+"_content' type='text' value='" + content + "' onchange='editText(&quot;" + objID + "_content&quot;,&quot;" + element.id + "&quot;)'></input>  " +
				//selector for link for the element
				"<span class='link_label'>"+BHCMSLABEL.link_label+"</span>" +
				" <select id='" + ELEM_LNK_PREFIX + element.id + "' onchange='editLink(&quot;" + element.id + "&quot;)'></select>  "+
			"</div>";
}


/** generate and return html code to manipulate the link of a general item and its text if it is  */
function generateItemDiv(elementId){
	// get text and page from preview frame to put in content tab's corresponding textfields and drop downs
	return  "<hr class='hr2'/>" +
			"<div style='width:100%;'>"+
			"<span class='item_id_label'>"+BHCMSLABEL.item_id_label+"</span>" + elementId + "   "+
			//selector for link for the element
				"<span class='link_label'>"+BHCMSLABEL.link_label+"</span>" +
				": <select id='" + ELEM_LNK_PREFIX + elementId + "' onchange='editLink(&quot;" + elementId + "&quot;)'></select>  "+
				"<button class='remove_item_button' type='button' id='"+elementId+"_remove' onclick='removeItem(&quot;"+elementId + "&quot);')>"+BHCMSLABEL.remove_item_button+"</button>" +
			"</div>";
}

function generateUnknownDiv(elementId){
	return "<hr class='hr2'/>"+
				"<span class='element_id'>"+BHCMSLABEL.element_id+"</span>" +
				" <div style='width:100%;'>" + elementId +"</div>";
}

/** adds an element to the content tab, surrounding with a border to separate it visually*/
function appendContentTab(stringToAppend, numberOfElements){
	if (stringToAppend){
		divToAppend = document.createElement('div');
		$(divToAppend).append(stringToAppend);
		$(divToAppend).find('hr').first().remove();
		$(divToAppend).css('padding', '2px');
		$(divToAppend).css('margin', '2px');
		if (stringToAppend.indexOf(BHCMSLABEL.appendable_label)>0){
			$("#content_tab").append("<br>");
		} else {
			if ($(divToAppend).children().length != 1 && numberOfElements == 1){
				//remove the " Item ID: " etc description 
				$(divToAppend).find('div').first().remove();
				$(divToAppend).find('hr').first().remove();
			}
			$(divToAppend).css('border', '2px brown solid');
		}
		$("#content_tab").append(divToAppend);
	}
}

// print options for image select dynamically
function printPicOptions(){
	$("#content_tab").find("select").each(function() {
		if (this.id.indexOf(IMG_SRC_PREFIX)==0){
			for(var i = 0; i < galleryImages.length; i=i+IMGS_ARRAY_DIMENSIONS) 
			{
				//the id of the element in the preview frame
				var objID = this.id.replace(IMG_SRC_PREFIX,"");
				//the source of the picture for that element
				var picture = $(htmlObject).find('#' + objID).attr("src");
				//get the image source for this object
				// option with value of resource id, text as resource description and extension from db
				// with dynamic id of select element
				if (i==0) {
					$('#' + this.id).append(
						"<option value='-1' selected='selected'>Please select an image</option>");
				}
				// picture in iframe is selected from dropdown in content view
				if (picture.indexOf(galleryImages[i] + "_original") !== -1) {
					$('#' + this.id).append(
						"<option value='" + galleryImages[i+IMGS_FILE_NAME_OFFSET] + "_original." + galleryImages[i+IMGS_FILE_EXTENS_OFFSET] + "' selected>" + galleryImages[i+IMGS_DESCRIPTION_OFFSET] + "</option>");
				} else {
					$('#' + this.id).append(
						"<option value='" + galleryImages[i+IMGS_FILE_NAME_OFFSET] + "_original." + galleryImages[i+IMGS_FILE_EXTENS_OFFSET] + "'>" + galleryImages[i+IMGS_DESCRIPTION_OFFSET] + "</option>");
				}
			}	
		}
	});
}

// print options for link select dynamically
function printLinkOptions(){
	$("#content_tab").find("select").each(function() {
		if (this.id.indexOf(ELEM_LNK_PREFIX) == 0){
			var currentLink = $(htmlObject).find('#'+ this.id).attr("href");
			for(var i = 0; i < pages.length; i = i + PAGES_ARRAY_DIMENSIONS) 
			{
				if (i==0) {
					$('#' + this.id).append(
						"<option value='-1' selected='selected'>Please select a page</option>");
				}
				if ((currentLink) && (currentLink.indexOf(pages[i]) !== -1)) {
					// option with value of page id and page name from db
					// with dynamic id of select element and fetched page from preview frame selected
					$('#' + this.id).append(
						"<option value='" + pages[i + PAGES_ID_OFFSET] + "' selected>" + pages[i + PAGES_TITLE_OFFSET] + "</option>");
				} else {
					$('#' + this.id).append(
						"<option value='" + pages[i + PAGES_ID_OFFSET] + "'>" + pages[i + PAGES_TITLE_OFFSET] + "</option>");
				}
			}	
		}
	});
}

//add an appendable item to the current list of items
function addAppendableItem(appendableContainerID)
{
	//if there was only one child of the appendable container, which is invisible - redisplay it
	if (($(htmlObject).find("."+appendableContainerID+"_item").length == 1) && 
		($(htmlObject).find("."+appendableContainerID+"_item").css('display') == "none" ))
	{
		//$(htmlObject).find("."+appendableContainerID+"_item").show();
		//display item
		$(htmlObject).find("."+appendableContainerID+"_item").css('display', '');
		//make it editable so it will appear in teh content tab
		$(htmlObject).find("."+appendableContainerID+"_item").addClass("editable");
	} 
	//otherwise create a new element and append it
	else 
	{	
		//get a copy of one of the children of the appendable container
		itemToAppend = $(htmlObject).find("."+appendableContainerID+"_item").first().clone();
		//prompt the user to provide a new id for the element	
		var newID=prompt("Please enter a unique item id:", $(itemToAppend).attr('id'));
		
		//check if there are any unallowed symbols in the new id
		var symbols = "!@#$&;^&*()~`?|";
		var fordbiddenChars = false
		for(var i=0,l=symbols.length;i<l;i++){
		  if(newID.indexOf(symbols.charAt(i)) >= 0){
		  	fordbiddenChars = true;
		  	break;
		  };
		}
		//check the id is legitimate and unique
		if ((newID!=undefined) && (!fordbiddenChars) && ($(htmlObject).find("#"+newID).length==0) && (!newID.indexOf(" ")>=0))
		{
			//assign the new id to the object
		 	$(itemToAppend).attr('id', newID);
		 	//change the id of each child of the appended view
		 	$(itemToAppend).find("*").each(function(){
					var childID = $(this).attr('id');
					if (childID != undefined){
						childID = childID.replace($(htmlObject).find("."+appendableContainerID+"_item").first().attr('id')+"_","");
						$(this).attr('id', newID+"_"+childID);
					}
			});		 	
		 	//append the new item to the container
			itemToAppend.appendTo($(htmlObject).find("#"+appendableContainerID));
		} 
		else 
		{
			alert("id should be unique, letters only, not empty and with no spaces");
		}
	}
	refreshPreview();
	pageChanges[currentPageId]=true;  
	//refresh the content list
	get_iframe();
}

//remove the last child of the apnendable container
function removeAppendableItem(appendableContainerID)
{
	//if there is only one child left of the appendable container - don't delete it, just hide it
	//if we remove the final child, we will loose the dom information and can not reconstruct later
	if ($(htmlObject).find("."+appendableContainerID+"_item").length == 1){
		//$(htmlObject).find("."+appendableContainerID+"_item").hide(); //or set css display :none
		$(htmlObject).find("."+appendableContainerID+"_item").css('display', 'none');
		//remove the editable class so its not displayed in the content view
		$(htmlObject).find("."+appendableContainerID+"_item").removeClass("editable");
	} else {
		//remove the last child
		$(htmlObject).find("."+appendableContainerID+"_item").last().remove(); 
	}
	refreshPreview();
	pageChanges[currentPageId]=true;  
	//refresh the content list
	get_iframe();
}

/** remove an element from the view */
function removeItem(containerID){
	$(htmlObject).find("#"+containerID).remove(); 
	refreshPreview();
	pageChanges[currentPageId]=true;  
	//refresh the content list
	get_iframe();
}

//function to edit map latitude and longitude
function editMap()
{
	var latitude = $("#MapLaltitude").val();
 	var longitude = $("#MapLongitude").val();
 	var googleZoom = $("#MapZoom").val();
	$(htmlObject).find('#latitude').val(latitude);
	$(htmlObject).find('#longitude').val(longitude);
	$(htmlObject).find('#mapZoom').val(googleZoom);
	//refresh the view without redrawing the whole iframe
	document.getElementById('preview_frame').contentWindow.setLatitude(latitude);
 	document.getElementById('preview_frame').contentWindow.setLongitude(longitude);
 	document.getElementById('preview_frame').contentWindow.setZoom(googleZoom);
 	pageChanges[currentPageId]=true; 
}

//function that edits the text of an element with class editable
function editText(selectTag, idOfElement) 
{
	var x = document.getElementById(selectTag);
	$(htmlObject).find('#' + idOfElement).text(x.value);
	refreshPreview();
	pageChanges[currentPageId]=true;  
}	
	
//function that edits the id of an element with class editable
function editId(selectTag, idOfElement) 
{
	var x = document.getElementById(selectTag);
	if (x.value!=null && $(htmlObject).find("#"+x.value).length == 0)
		{
			$(htmlObject).find('#' + idOfElement).attr('id', x.value);
			refreshPreview();
			pageChanges[currentPageId]=true;
			//refresh the content list
			get_iframe();
		} 
		else 
		{
			alert("id should be unique and not empty");
		}  
}	

//function that changes the picture source to a predefined source
function editPicture(sourceOfElement, idOfElement) 
{
	// selectedOption is the option that gets selected from the select (drop down list) of available images in gallery
	// get value of selected option
	var selectedOption = $("#" + IMG_SRC_PREFIX + idOfElement).val();
	// if default value is selected (blank)
	if (selectedOption == "-1") {
		// put some logo
		sourceOfElement = ""
		selectedOption = DEF_IMAGE_PATH;
	}
	// change source of element in preview_frame
	$(htmlObject).find('#' + idOfElement).attr('src', sourceOfElement + selectedOption);
	refreshPreview();
	pageChanges[currentPageId]=true;  
}

// sets alt and title of image depending on input text field before image selector
function editAltAndTitle(selectTag, idOfElement) {
	// get the value of the textfield next to the picture
	var x = document.getElementById(selectTag);
	// set it as alt and title of image
	$(htmlObject).find('#' + idOfElement).attr('title', x.value);
	$(htmlObject).find('#' + idOfElement).attr('alt', x.value);
	refreshPreview();
	pageChanges[currentPageId]=true;  
}

//function that changes a link of an iframe element with an id - editable
function editLink(idOfElement) 
{
	//check if the element already has a link - i.e. if it's parent is surrounded by 
	//<a> tag with an id of ELEM_LNK_PREFIX + the id of the element
	var parentID = $(htmlObject).find('#' + idOfElement).parent().attr('id');
	//get the selectead link for this element from the option in the content tab
	var selectedOption = $("#" + ELEM_LNK_PREFIX + idOfElement).val() + ".html";
	if (parentID == (ELEM_LNK_PREFIX + idOfElement)){
		//change the link
		$(htmlObject).find('#' + parentID).attr('href', selectedOption);
	} else {
		//create a href wrapper
		$(htmlObject).find('#' + idOfElement).wrap("<a id='"+ELEM_LNK_PREFIX+ idOfElement+"' href='"+selectedOption+"' />");
	}
	refreshPreview();
	pageChanges[currentPageId]=true;  
}

//variable to store element that has been clicked before
var previousTemplate;
var previousPage;
var previousTheme;

//function to mark the current frame, template and colorTheme selected 
//If new is selected - deselects the previous one
function redLine(clickedDiv) {
	//deselect previous object
	//check if a theme/configuraiton was clicked
	if (clickedDiv.indexOf("config") >= 0)
	{
		//check if any theme/configuration was previously clicked
		if ($("#" + previousTheme) != null) {
			//Get the previously clicked div and change it's border to 0
			$("#" + previousTheme).css("border", "0px");
		}
		previousTheme = clickedDiv;
	}
	//check if a page preview
	else if(clickedDiv.indexOf("page") >= 0) {
		//check if any page was previously clicked
		if ($("#" + previousPage) != null) {
			//Get the previously clicked div and change it's border to 0
			$("#" + previousPage).css("border", "0px");
		}
		//store the id of clickeDiv in previousDiv
		previousPage = clickedDiv;
	} 
	else 
	//else it is a template
	{
		//check if any page was previously clicked
		if ($("#" + previousTemplate) != null) {
			//Get the previously clicked div and change it's border to 0
			$("#" + previousTemplate).css("border", "0px");
		}
		//store the id of clickeDiv in previousDiv
		previousTemplate = clickedDiv;
	}
	
	//mark the clicked item with a red line
	$("#" + clickedDiv).css("border", "solid 4px #FF0000");
}
//temp page

//function that sets up the color for  the preview frame 
//(background-color, Title color, text color and button color as well as any kind of text color) 
function changeColor(bgColor,mainTextColor,normalTextColor,buttonColor)
{
	$(htmlObject).find('body, .mainContainer').css("background-color", bgColor);
	$(htmlObject).find('h1, h2, h3 ').css("color", mainTextColor);
	$(htmlObject).find('body, p, button, li, a').css("color", normalTextColor);
	$(htmlObject).find('button, li, ul, .footer').css("background-color", buttonColor);
	refreshPreview();
	pageChanges[currentPageId]=true;  
}

/**function that checks if there is a title set for the preview frame document
*if there is no title tag appends a title tag with title text value
*if there is a title tag changes the text value of tag
* @inputTag - id of the input tag in manage view where the title is inserted
*/
function setTitle(inputTag) 
{
	var titleText = document.getElementById(inputTag);
	if($(htmlObject).find("title").html() == null)
	{
			var $head = $(htmlObject).find("head"); 
			$head.append("<title>"+titleText.value+"</title>" );
	}
	else
	{
			$(htmlObject).find("title").html(titleText.value);
	}
	refreshPreview();
	pageChanges[currentPageId]=true;  
}

//returns the title of the current page
function getTitle(){
	return $(htmlObject).find("title").html();
}

//function to adjust the size and font of preview frames element depending on selection
function changeFontFamily(fontTagType) {
	 var fontTagValue = document.getElementById(fontTagType);
	//changes font family type for all elements of document
	if(fontTagType == "fontFamily"){
	$(htmlObject).find('body, h1, h2, h3, body, p, button, li, a').css("font-family", fontTagValue.value);
	refreshPreview();
	pageChanges[currentPageId]=true;  
	}
	//changes font size for all elements of document
	else if(fontTagType == "fontSize"){
	$(htmlObject).find('body, a').css("font-size", fontTagValue.value + "%");
	refreshPreview();
	pageChanges[currentPageId]=true; 
	}
}