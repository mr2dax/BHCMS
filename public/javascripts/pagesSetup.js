////set the title field of the the setup tab
function setSetupTitle(newTitle){
	$("#titleInputTag").val(newTitle);
}
// set the font-family of the currently selected page at the setup tab, if none found then set it to Arial
function setSetupFontStyle(newValue){
	var family = newValue;
	if (newValue == ""){
		family = "Arial";
	}
	$("#fontFamily").val(newValue);
}
// set the font-family of the currently selected page at the setup tab, if none found then set it to 100(%)
function setSetupFontSize(newValue){
	var size = newValue.slice(0,newValue.length-1);
	if (newValue == ""){
		size = 100;
	}
	$("#fontSize").val(size);
}