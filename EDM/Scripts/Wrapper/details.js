
function OpenAttachment(url) 
{        
    if(SessionExists())
    {
        if (url.indexOf('/') > -1) {
            url = url + "&printserverlocation=" + printSeverLocation;
            
            var height = 677;
            var width = 750;
            
            if(url.indexOf('Base')>-1){
                height = 600;
                width = 700;
            }
           
            popup = OpenChild(COMPONENT_BASE_PATH + url, "Attachment", true,  width, height, 'no', 'no');
        } else {
            alert(url);
        }
    }
}



function OpenPartlijst(sqlFrom, whereClause,repCode) {

    if(SessionExists())
    {     
        //popup = OpenChild(COMPONENT_BASE_PATH + '/Templates/partlist.asp?id='+ id +'&rev='+ revision, '', true, 800, 600, 'yes', 'yes');       
        popup = OpenChild('partlist.aspx?sqlFrom='+ sqlFrom +'&whereClause='+ whereClause+'&repCode='+ repCode, '', true, 800, 600, 'yes', 'yes');       
    }
}

function OpenWhereUsed(){

      if(SessionExists())
    {     
        //popup = OpenChild(COMPONENT_BASE_PATH + '/Templates/partlist.asp?id='+ id +'&rev='+ revision, '', true, 800, 600, 'yes', 'yes');       
        popup = OpenChild('WhereUsed.aspx', '', true, 800, 600, 'yes', 'yes');       
    }
}

function OpenHistory(tableName,keyvalue) 
{
    if(SessionExists())
    {        
       popup = OpenChild(COMPONENT_BASE_PATH + '/Templates/history.asp?keyvalue='+ keyvalue+'&tableName='+tableName, '', true, 800, 600, 'yes', 'no');     
    }
}


function OpenDocument(filePath) {
    window.open("TaskAttachmentLoader.aspx?filePath=" + filePath);

}