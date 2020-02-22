
function ToggleVersion() {
    var caption = document.getElementById('btnVersionController').value;
    if (caption == "OriginalVersion") {
        LoadViewerContent('dwf', 'nonReportTabPanel2', false);
    } else {
        LoadViewerContent('dwf', 'nonReportTabPanel2', true);
    }
}

function OpenPostUpdate() 
{
    if(SessionExists())
    {
        OpenChild("PostUpdate.aspx", "PostUpdateRequest", true, 560, 425, "yes", "no", false);
    }
}

function SaveAsRedline()
{
    if (SessionExists()) {  
          
        var relFilePath = drawingUrl.split('?')[1].split('&')[0];
        relFilePath = relFilePath.split('=')[1];
        var sessionid = Get_Cookie("sessionid");
        relFilePath = relFilePath.replace("_Redline.dwf", ".dwf");
        
        var fileName = relFilePath.substring(relFilePath.lastIndexOf('\\')+1);
        //var subPath = relFilePath.substring(0,relFilePath.lastIndexOf('\\'));
        var docSaveUrl = docSharedPath.replace(/@@@/g, "\\") + fileName.toLowerCase().replace(".dwf", "_Redline.dwf");
        
        docSaveUrl = docSaveUrl + sessionid ;
        var ADViewer = document.getElementById("ADViewer");       
        ADViewer.SaveAs(docSaveUrl);
        CheckFileSavedAlready(docSaveUrl, relFilePath);
        setTimeout(function() {
            var btnVersionController = document.getElementById('btnVersionController');
            var disableStatus = btnVersionController.getAttribute("disabled");
            btnVersionController.value = "OriginalVersion";
            btnVersionController.disabled = false;
        }, 1000);     
    }
}

function CheckFileSavedAlready(docSaveUrl, relFilePath) {
    docSaveUrl = docSaveUrl.replace(/\\/g, "@@@");
    relFilePath = relFilePath.replace(/\\/g, "@@@");
    //docSharePath = docSharePath.replace(/\\/g, "@@@");
    var url = kitServerPath + "/DownloadFullXML.aspx?redline=" + docSaveUrl + "&relFileName=" + relFilePath + "&" + new Date().getTime();
    document.getElementById("iframUploadRedline").src = url;
}

function CheckRedline() 
{
    if (!tabPanel) {
        return;
    }

    if (tabPanel.getActiveTab().title == 'DWF Viewer') 
    {
        try 
        {
            var ADViewer = document.getElementById("ADViewer");
            var Cmds = ADViewer.ECompositeViewer.Commands;
            var ECompViewer = ADViewer.ECompositeViewer;
            var AllObjects = ECompViewer.Sections(1).Content.Objects(2);
            if (AllObjects.Count > 0) {
                var saveFlag = window.confirm("Unsaved redline found, Do you want to save?");
                if (saveFlag) {
                    SaveAsRedline();
                }
            }
        } catch (e) 
        {
        }
    }       
}

function Get_Cookie( check_name ) {
	// first we'll split this cookie up into name/value pairs
	// note: document.cookie only returns name=value, not the other components
	var a_all_cookies = document.cookie.split( ';' );
	var a_temp_cookie = '';
	var cookie_name = '';
	var cookie_value = '';
	var b_cookie_found = false; // set boolean t/f default f

	for ( i = 0; i < a_all_cookies.length; i++ )
	{
		// now we'll split apart each name=value pair
		a_temp_cookie = a_all_cookies[i].split( '=' );


		// and trim left/right whitespace while we're at it
		cookie_name = a_temp_cookie[0].replace(/^\s+|\s+$/g, '');

		// if the extracted name matches passed check_name
		if ( cookie_name == check_name )
		{
			b_cookie_found = true;
			// we need to handle case where cookie has no value but exists (no = sign, that is):
			if ( a_temp_cookie.length > 1 )
			{
				cookie_value = unescape( a_temp_cookie[1].replace(/^\s+|\s+$/g, '') );
			}
			// note that in cases where cookie is initialized but no value, null is returned
			return cookie_value;
			break;
		}
		a_temp_cookie = null;
		cookie_name = '';
	}
	if ( !b_cookie_found )
	{
		return null;
	}
}

