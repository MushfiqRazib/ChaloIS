function LoadDocument(url) 
{
    if (url != "") 
    {        
        var file = Getfilename(url);
        file = file.split(".");
        file[1] = Trim(file[1], ' ');

        url = "./loader.asp?docpath=" + url + "&name=" + file[0] + "&ext=" + file[1] + "&nocache=" + new Date().getTime();
        
        var vwrHTML = '<embed src="' + url + '" href="' + url + '" height="100%" width="100%">' +
                    '  <noembed>Your browser does not support embedded PDF files.</noembed>' +
                    '</embed>';
    }
    else {
        //*** No document!
        var vwrHTML = "<big>Geen document beschikbaar.</big>";
    }

    //*** Put HTML into viewer container.
    setElementAttrib("Document", "innerHTML", vwrHTML);
}

function Getfilename(url) {
    var splitter = url.split("$$$$");
    var filename = splitter[splitter.length - 1];
    return filename;
}