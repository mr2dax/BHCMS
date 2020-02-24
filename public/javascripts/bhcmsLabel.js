
//==============================================================================
// BHCMS - Label
//==============================================================================
/*
 * BHCMS Label is used to support multi-language interfaces.
 * Any string displayed in the CMS is fetched from BHCMSLABEL
 */
BHCMSLABEL =
{
    // content loaded dynamically from XML
}
BHCMSLABEL._loaded = false;

/**
 * Load labels from an XML file.
 * This function can be called many times.
 * Existing entries are overridden.
 * @languageXml the xml containing the labels
 */
BHCMSLABEL.loadLabels = function(languageXml)
{
    var jqxml = $(languageXml);
    var root = jqxml.children("Translation")[0];
    this._rec_load($(root), this);
    BHCMSLABEL._loaded = true;
}

BHCMSLABEL._rec_load = function(xml, object)
{
    // Strings
    var strings = xml.children("String");
    for(var i = 0; i < strings.length; i++)
    {
        var str = $(strings[i]);
        var name = str.attr("name");
        var value = str.text();
        //apply the strings to the elemnents, names is the objects class name
        if(object[name])
        {
            if(object[name].TYPE == "content"){
                console.error("LABEL: Tried to override content with string. " +
                    " Name: " + name);
                return;
            }
            object[name].str = value;
        }
        else if(!BHCMSLABEL._loaded)
            object[name] = new BHCMSLABEL.String(value);
		//apply the text to the elements in the view
        $("."+ name).text(value);
    }

    // Contents
    var contents = xml.children("Content");
    for(var i = 0; i < contents.length; i++)
    {
        var contentXml = $(contents[i]);
        var name = contentXml.attr("name");
        if(object[name]){
            if(object[name].TYPE != "content"){
                OELOG.error("LABEL: Tried to override string with content. "
                    + " Name: " + name);
                return;
            }
        }
        else if(!BHCMSLABEL._loaded)
        {
            var contentObj = new BHCMSLABEL.Content();
            object[name] = contentObj;
        }
        if(object[name])
            this._rec_load(contentXml, object[name]);
    }

}

//==============================================================================
// Content
//==============================================================================

/**
 * Class for content
 */
BHCMSLABEL.Content = function()
{
}

BHCMSLABEL.Content.prototype.TYPE = "content";


//==============================================================================
// BHCMS - Label - String
//==============================================================================

/**
 * This class wraps a string.
 * It supports further functions to replace wildcards etc.
 */
BHCMSLABEL.String = function(string)
{
    this.str = string;
}
BHCMSLABEL.String.prototype.TYPE = "string";

BHCMSLABEL.String.prototype.replace = function(data)
{
    try{
        return sprintf(this.str, data);
   }catch(e){
        console.error("LABEL.replace ERROR: " + e);
        return this.str;
   }
}

BHCMSLABEL.String.prototype.toString = function()
{
    return this.str;
}