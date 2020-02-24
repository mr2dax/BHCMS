// Namespace
if (typeof BHCMS == 'undefined') {
  BHCMS = {};
}

/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

BHCMS = {
    language : "ja_JP"
}

//------------------------------------------------------------------------------
// Inititialization
//------------------------------------------------------------------------------

/**
 * Init the languages.
 * @language language of the game
 */
BHCMS.init = function(language)
{
    if(language) this.language = language;
 // send ajax request to initialize BHCMSLABEL
        $.ajax({
            url: "/lang/gui_" + this.language + ".xml?uniq=" +
                Math.round(Math.random()*999999),
            context : this,
            success:
                function(data){
                    BHCMSLABEL.loadLabels(data);
                },
            error : function(){
                    console.error("Failed to load language: " + this.language);
                },
            dataType: "xml"
        });
}