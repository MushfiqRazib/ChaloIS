<table style="font: normal 10px Verdana">
  <tr>
    <td style="padding-right: 6px">Rij:</td>
    <td style="padding-top: 0px" nowrap>
      <button class="Navigator" title="Eerste pagina" onclick="page_first()" onfocus="this.blur()"><img src="./image/nav_firstpage.gif" alt="Eerste pagina"></button><button class="Navigator" title="Vorige pagina" onclick="page_previous()" onfocus="this.blur()"><img src="./image/nav_prevpage.gif"  alt="Vorige pagina"></button><button class="Navigator" title="Vorige record" onclick="row_previous()" onfocus="this.blur()"><img src="./image/nav_prevrow.gif"   alt="Vorige record"></button>
    </td>
    <td><input type="text" class="RowNumber" id="RecordNumber" value="0" onkeypress="return isRownum(event)" onpaste="return false"></td>
    <td style="padding-top: 0px">
      <button class="Navigator" title="Volgende record" onclick="row_next()" onfocus="this.blur()"><img src="./image/nav_nextrow.gif" alt="Volgende record"></button><button class="Navigator" title="Volgende pagina" onclick="page_next()" onfocus="this.blur()"><img src="./image/nav_nextpage.gif" alt="Volgende pagina"></button><button class="Navigator" title="Laatste pagina"  onclick="page_last()" onfocus="this.blur()"><img src="./image/nav_lastpage.gif" alt="Laatste pagina"></button>
    </td>
    <td style="padding-left: 6px" id="RecordCount" nowrap>van 0</td>
  </tr>
</table>