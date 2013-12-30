<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
    <head>
        <title></title>
        <script src="../script/jquery.min.js" type="text/javascript"></script>
        <script src='../script/qj2.js' type="text/javascript"></script>
        <script src='qset.js' type="text/javascript"></script>
        <script src='../script/qj_mess.js' type="text/javascript"></script>
        <script src="../script/qbox.js" type="text/javascript"></script>
        <script src='../script/mask.js' type="text/javascript"></script>
        <link href="../qbox.css" rel="stylesheet" type="text/css" />
        <link href="css/jquery/themes/redmond/jquery.ui.all.css" rel="stylesheet" type="text/css" />
        <script src="css/jquery/ui/jquery.ui.core.js"></script>
        <script src="css/jquery/ui/jquery.ui.widget.js"></script>
        <script src="css/jquery/ui/jquery.ui.datepicker_tw.js"></script>
        <script type="text/javascript">
            this.errorHandler = null;
            function onPageError(error) {
                alert("An error occurred:\r\n" + error.Message);
            }
            q_desc = 1;
            q_tables = 's';
            var q_name = "vcc";
            var q_readonly = [];
            var q_readonlys = [];
            var bbmNum = [];
            var bbsNum = [];
            var bbmMask = [];
            var bbsMask = [];
            q_sqlCount = 6;
            brwCount = 6;
            brwList = [];
            brwNowPage = 0;
            brwKey = 'noa';
            aPop = new Array(['txtCustno', 'lblCust', 'cust', 'noa,comp,nick,tel,zip_fact,addr_fact,paytype', 'txtCustno,txtComp,txtNick,txtTel,txtPost,txtAddr,txtPaytype', 'cust_b.aspx']
                ,['txtAddr', '', 'view_road', 'memo,zipcode', '0txtAddr,txtPost', 'road_b.aspx']);
            brwCount2 = 12;
  
            $(document).ready(function() {
                bbmKey = ['noa'];
                bbsKey = ['noa', 'noq'];
                q_brwCount();
                q_gt(q_name, q_content, q_sqlCount, 1, 0, '', r_accy);
            });
            function main() {
                if (dataErr) {
                    dataErr = false;
                    return;
                }
                mainForm(1);
            }
            function sum() {
                if (!(q_cur == 1 || q_cur == 2))
                    return;
                $('#cmbTaxtype').val((($('#cmbTaxtype').val()) ? $('#cmbTaxtype').val() : '1'));
                $('#txtMoney').attr('readonly', true);
                $('#txtTax').attr('readonly', true);
                $('#txtTotal').attr('readonly', true);
                $('#txtMoney').css('background-color', 'rgb(237,237,238)').css('color', 'green');
                $('#txtTax').css('background-color', 'rgb(237,237,238)').css('color', 'green');
                $('#txtTotal').css('background-color', 'rgb(237,237,238)').css('color', 'green');

                var t_mount = 0, t_price = 0, t_money = 0, t_moneyus = 0, t_weight = 0, t_total = 0, t_tax = 0;
                var t_mounts = 0, t_prices = 0, t_moneys = 0, t_weights = 0;
                var t_unit = '';
                var t_float = q_float('txtFloata');
                var t_tranmoney = dec($('#txtTranmoney').val());
                for (var j = 0; j < q_bbsCount; j++) {
                    t_prices = q_float('txtPrice_' + j);
                    t_mounts = q_float('txtMount_' + j);
                   
                    t_moneys = q_mul(t_prices, t_mounts);
                    t_mount = q_add(t_mount, t_mounts);
                    t_money = q_add(t_money, t_moneys);
                    $('#txtTotal_' + j).val(FormatNumber(t_moneys));
                }
                t_total=t_money;
                t_tax=0;
                t_taxrate = parseFloat(q_getPara('sys.taxrate')) / 100;
                switch ($('#cmbTaxtype').val()) {
                    case '1':
                        // 應稅
                        t_tax = round(q_mul(t_money, t_taxrate), 0);
                        t_total = q_add(t_money, t_tax);
                        break;
                    case '2':
                        //零稅率
                        t_tax = 0;
                        t_total = q_add(t_money, t_tax);
                        break;
                    case '3':
                        // 內含
                        t_tax = q_sub(t_money,round(q_div(t_money, q_add(1, t_taxrate)), 0));
                        t_total = t_money;
                        t_money = q_sub(t_total, t_tax);
                        break;
                    case '4':
                        // 免稅
                        t_tax = 0;
                        t_total = q_add(t_money, t_tax);
                        break;
                    case '5':
                        // 自定
                        $('#txtTax').attr('readonly', false);
                        $('#txtTax').css('background-color', 'white').css('color', 'black');
                        t_tax = round(q_float('txtTax'), 0);
                        t_total = q_add(t_money, t_tax);
                        break;
                    case '6':
                        // 作廢-清空資料
                        t_money = 0, t_tax = 0, t_total = 0;
                        break;
                    default:
                }
                
                $('#txtMoney').val(FormatNumber(t_money));
                $('#txtTax').val(FormatNumber(t_tax));
                $('#txtTotal').val(FormatNumber(t_total));
            }

            function mainPost() {// 載入資料完，未 refresh 前
                q_getFormat();
                bbmMask = [['txtDatea', r_picd], ['txtMon', r_picm]];
                q_mask(bbmMask);
                q_cmbParse("cmbTypea", q_getPara('vcc.typea'));
                q_cmbParse("cmbTaxtype", q_getPara('sys.taxtype'));
                //=======================================================
                $("#cmbTypea").focus(function() {
                    var len = $(this).children().length > 0 ? $(this).children().length : 1;
                    $(this).attr('size', len + "");
                }).blur(function() {
                    $(this).attr('size', '1');
                });
                $("#cmbTaxtype").change(function(e) {
                    sum();
                });
                //=====================================================================
                /* 若非本會計年度則無法存檔 */
                $('#txtDatea').focusout(function() {
                    if ($(this).val().substr(0, 3) != r_accy) {
                        $('#btnOk').attr('disabled', 'disabled');
                        alert(q_getMsg('lblDatea') + '非本會計年度。');
                    } else {
                        $('#btnOk').removeAttr('disabled');
                    }
                });
                $('#lblOrdeno').click(function() {
                    if(!(q_cur==1 || q_cur ==2))
                        return;
                    btnOrdes();
                });
                $('#lblAccno').click(function() {
                    q_pop('txtAccno', "accc.aspx?" + r_userno + ";" + r_name + ";" + q_time + ";accc3='" + $('#txtAccno').val() + "';" + $('#txtDatea').val().substring(0, 3) + '_' + r_cno, 'accc', 'accc3', 'accc2', "92%", "1054px", q_getMsg('btnAccc'), true);
                });
                $('#txtTax').change(function() {
                    sum();
                });
                $('#txtAddr').change(function() {
                    var t_custno = trim($(this).val());
                    if (!emp(t_custno)) {
                        focus_addr = $(this).attr('id');
                        var t_where = "where=^^ noa='" + t_custno + "' ^^";
                        q_gt('cust', t_where, 0, 0, 0, "");
                    }
                });
                $('#txtAddr2').change(function(){
                    var t_custno = trim($(this).val());
                    if(!emp(t_custno)){
                        focus_addr = $(this).attr('id');
                        var t_where = "where=^^ noa='" + t_custno + "' ^^";
                        q_gt('cust', t_where, 0, 0, 0, "");
                    }  
                });
                $('#lblInvono').click(function() {
                    if($('#txtInvono').val().length>0)
                        q_pop('txtInvono', "vcca.aspx?" + r_userno + ";" + r_name + ";" + q_time + ";noa='" + $('#txtInvono').val() + "';" + r_accy, 'vcca', 'noa', 'datea', "95%", "95%px", q_getMsg('lblInvono'), true);
                });
            }

            function q_boxClose(s2) {///   q_boxClose 2/4
                var ret;
                switch (b_pop) {
                    case q_name + '_s':
                        q_boxClose2(s2);
                        ///   q_boxClose 3/4
                        break;
                }
                b_pop = '';
            }
            function q_gtPost(t_name) {/// 資料下載後 ...
                switch (t_name) {
                    case 'getVccatax':
                        var as = _q_appendData("vcca", "", true);
                        if (as[0] != undefined) {
                            $('#txtVccatax').val(q_trv(as[0].tax,0,1));
                            var t_noa = $('#txtNoa').val();
                            for(var i=0;i<abbm.length;i++){
                                if(abbm[i].noa==t_noa){
                                    abbm[i].vccatax=as[0].tax;
                                    break;
                                }
                            }               
                        }
                        break;
                    case 'getAcomp':
                        var as = _q_appendData("acomp", "", true);
                        if(as[0]!=undefined){
                            $('#txtCno').val(as[0].noa);
                            $('#txtAcomp').val(as[0].nick);
                        }
                        Unlock(1);
                        $('#txtNoa').val('AUTO');
                        $('#txtDatea').val(q_date());
                        $('#txtMon').val(q_date().substring(0,6));
                        $('#txtDatea').focus();
                        break;
                    case 'cust':
                        var as = _q_appendData("cust", "", true);
                        if (as[0] != undefined && focus_addr != '') {
                            $('#' + focus_addr).val(as[0].addr_fact);
                            focus_addr = '';
                        }
                        break;
                    case q_name:
                        if (q_cur == 4)// 查詢
                            q_Seek_gtPost();
                        break;
                    default:
                } 
            }

            function btnOk() {
                Lock(1, {
                    opacity : 0
                });
                if ($('#txtDatea').val().length == 0 || !q_cd($('#txtDatea').val())) {
                    alert(q_getMsg('lblDatea') + '錯誤。');
                    Unlock(1);
                    return;
                }
                if ($('#txtMon').val().length == 0)
                    $('#txtMon').val($('#txtDatea').val().substring(0, 6));
                if (!q_cd($('#txtMon').val() + '/01')) {
                    alert(q_getMsg('lblMon') + '錯誤。');
                    Unlock(1);
                    return;
                }
                if ($('#txtDatea').val().substring(0, 3) != r_accy) {
                    alert('年度異常錯誤，請切換到【' + $('#txtDatea').val().substring(0, 3) + '】年度再作業。');
                    Unlock(1);
                    return;
                }
                if ($.trim($('#txtNick').val()).length == 0 && $.trim($('#txtComp').val()).length > 0)
                    $('#txtNick').val($.trim($('#txtComp').val()).substring(0, 4));
                sum();
                
                var t_noa = trim($('#txtNoa').val());
                var t_date = trim($('#txtDatea').val());
                if (t_noa.length == 0 || t_noa == "AUTO")
                    q_gtnoa(q_name, replaceAll(q_getPara('sys.key_vcc') + (t_date.length == 0 ? q_date() : t_date), '/', ''));
                else
                    wrServer(t_noa);
            }
            function q_stPost() {
                if (!(q_cur == 1 || q_cur == 2))
                    return false;
                $('#txtVccatax').val(0);
                var t_noa = $('#txtNoa').val();
                for(var i=0;i<abbm.length;i++){
                    if(abbm[i].noa==t_noa){
                        abbm[i].vccatax=0;
                        break;
                    }
                } 
                var strSplit = xmlString.split(';');
                if(strSplit.length>=2){
                    abbm[q_recno]['accno'] = strSplit[0];
                    $('#txtAccno').val(strSplit[0]);
                    abbm[q_recno]['invono'] = strSplit[1];
                    $('#txtInvono').val(strSplit[1]);
                    if(strSplit[1].length>0)
                        q_gt('vcca',"where=^^noa='"+strSplit[1]+"'^^", 0, 0, 0, 'getVccatax', r_accy);
                }
                Unlock(1);
            }

            function _btnSeek() {
                if (q_cur > 0 && q_cur < 4)// 1-3
                    return;

                q_box('vccst_s.aspx', q_name + '_s', "500px", "530px", q_getMsg("popSeek"));
            }


            function bbsAssign() {/// 表身運算式
                for (var j = 0; j < q_bbsCount; j++) {
                    $('#lblNo_' + j).text(j + 1);
                    if (!$('#btnMinus_' + j).hasClass('isAssign')) {
                        $('#txtPrice_' + j).focusout(function() {
                            sum();
                        });
                        $('#txtMount_' + j).focusout(function() {
                            sum();
                        });
                        $('#txtTotal_' + j).focusout(function() {
                            sum();
                        });
                    }
                }
                _bbsAssign();
            }

            function btnIns() {
                _btnIns();
                $('#cmbTaxtype').val(1);
                Lock(1, {
                    opacity : 0
                });
                q_gt('acomp', '', 0, 0, 0, 'getAcomp', r_accy);
            }

            function btnModi() {
                if (emp($('#txtNoa').val()))
                    return;
                _btnModi();
                $('#txtDatea').focus();
                sum();
            }

            function btnPrint() {
                q_box("z_vccstp.aspx?" + r_userno + ";" + r_name + ";" + q_time + ";noa=" + $('#txtNoa').val() + ";" + r_accy, 'z_vccstp', "95%", "95%", q_getMsg('popPrint'));
            }

            function wrServer(key_value) {
                var i;

                $('#txt' + bbmKey[0].substr(0, 1).toUpperCase() + bbmKey[0].substr(1)).val(key_value);
                _btnOk(key_value, bbmKey[0], bbsKey[1], '', 2);
            }

            function bbsSave(as) {
                if (!as['product'] && !as['uno'] && parseFloat(as['mount'].length == 0 ? "0" : as['mount']) == 0 && parseFloat(as['weight'].length == 0 ? "0" : as['weight']) == 0) {
                    as[bbsKey[1]] = '';
                    return;
                }

                q_nowf();
                return true;
            }

            function refresh(recno) {
                _refresh(recno);
            }
            var x_bseq = 0;
            function q_popPost(s1) {
                switch (s1) {
                    default:
                    break;
                }

            }

            function readonly(t_para, empty) {
                _readonly(t_para, empty);
            }

            function btnMinus(id) {
                _btnMinus(id);
                sum();
            }

            function btnPlus(org_htm, dest_tag, afield) {
                _btnPlus(org_htm, dest_tag, afield);
                if (q_tables == 's')
                    bbsAssign();
            }

            function q_appendData(t_Table) {
                dataErr = !_q_appendData(t_Table);
            }

            function btnSeek() {
                _btnSeek();
            }

            function btnTop() {
                _btnTop();
            }

            function btnPrev() {
                _btnPrev();
            }

            function btnPrevPage() {
                _btnPrevPage();
            }

            function btnNext() {
                _btnNext();
            }

            function btnNextPage() {
                _btnNextPage();
            }

            function btnBott() {
                _btnBott();
            }

            function q_brwAssign(s1) {
                _q_brwAssign(s1);
            }

            function btnDele() {
                _btnDele();
            }

            function btnCancel() {
                _btnCancel();
            }


            function FormatNumber(n) {
                var xx = "";
                if (n < 0) {
                    n = Math.abs(n);
                    xx = "-";
                }
                n += "";
                var arr = n.split(".");
                var re = /(\d{1,3})(?=(\d{3})+$)/g;
                return xx + arr[0].replace(re, "$1,") + (arr.length == 2 ? "." + arr[1] : "");
            }
            function tipShow(){
                Lock(1);
                tipInit();
                var t_set = $('body');
                t_set.find('.tip').eq(0).show();//tipClose
                for(var i=1;i<t_set.data('tip').length;i++){
                    index = t_set.data('tip')[i].index;
                    obj = t_set.data('tip')[i].ref;
                    msg = t_set.data('tip')[i].msg;
                    shiftX = t_set.data('tip')[i].shiftX;
                    shiftY = t_set.data('tip')[i].shiftY;
                    if(obj.is(":visible")){
                        t_set.find('.tip').eq(index).show().offset({top:round(obj.offset().top+shiftY,0),left:round(obj.offset().left+obj.width()+shiftX,0)}).html(msg);
                    }else{
                        t_set.find('.tip').eq(index).hide();
                    }
                }
            }
            function tipInit(){
                tip($('#lblOrdeno'),'<a style="color:darkblue;font-size:16px;font-weight:bold;width:300px;display:block;">點擊【'+q_getMsg('lblOrdeno')+'】匯入訂單</a>',0,-15);
                tip($('#btnImportVcce'),'<a style="color:darkblue;font-size:16px;font-weight:bold;width:300px;display:block;">↓匯入派車單資料。</a>',-20,-15);
                tip($('#btnVcceImport'),'<a style="color:darkblue;font-size:16px;font-weight:bold;width:350px;display:block;">↑匯入裁剪、製管資料，需有訂單(未結案)。</a>',-20,20);
            }
            function tip(obj,msg,x,y){
                x = x==undefined?0:x;
                y = y==undefined?0:y;
                var t_set = $('body');
                if($('#tipClose').length==0){
                    //顯示位置在btnTip上
                    t_set.data('tip',new Array());
                    t_set.append('<input type="button" id="tipClose" class="tip" value="關閉"/>');
                    $('#tipClose')
                    .css('position','absolute')
                    .css('z-index','1001')
                    .css('color','red')
                    .css('font-size','18px')
                    .css('display','none')
                    .click(function(e){
                        $('body').find('.tip').css('display','none');
                        Unlock(1);
                    });
                    $('#tipClose').offset({top:round($('#btnTip').offset().top-2,0),left:round($('#btnTip').offset().left-15,0)});
                    t_set.data('tip').push({index:0,ref:$('#tipClose')});
                }
                if(obj.data('tip')==undefined){
                    t_index = t_set.find('.tip').length;
                    obj.data('tip',t_index);
                    t_set.append('<div class="tip" style="position: absolute;z-index:1000;display:none;"> </div>');
                    t_set.data('tip').push({index:t_index,ref:obj,msg:msg,shiftX:x,shiftY:y});
                }           
            }
            
            function combAddr_chg() {   /// 只有 comb 開頭，才需要寫 onChange()   ，其餘 cmb 連結資料庫
                if (q_cur==1 || q_cur==2){
                    $('#txtAddr2').val($('#combAddr').find("option:selected").text());
                    $('#txtPost2').val($('#combAddr').find("option:selected").val());
                }
            }
        </script>
        <style type="text/css">
            #dmain {
                overflow: hidden;
            }
            .dview {
                float: left;
                width: 300px;
                border-width: 0px;
            }
            .tview {
                border: 5px solid gray;
                font-size: medium;
                background-color: black;
            }
            .tview tr {
                height: 30px;
            }
            .tview td {
                padding: 2px;
                text-align: center;
                border-width: 0px;
                background-color: #FFFF66;
                color: blue;
            }
            .dbbm {
                float: left;
                width: 900px;
                /*margin: -1px;
                 border: 1px black solid;*/
                border-radius: 5px;
            }
            .tbbm {
                padding: 0px;
                border: 1px white double;
                border-spacing: 0;
                border-collapse: collapse;
                font-size: medium;
                color: blue;
                background: #cad3ff;
                width: 100%;
            }
            .tbbm tr {
                height: 35px;
            }
            .tbbm tr td {
                width: 10%;
            }
            .tbbm .tdZ {
                width: 1%;
            }
            .tbbm tr td span {
                float: right;
                display: block;
                width: 5px;
                height: 10px;
            }
            .tbbm tr td .lbl {
                float: right;
                color: black;
                font-size: medium;
            }
            .tbbm tr td .lbl.btn {
                color: #4297D7;
                font-weight: bolder;
            }
            .tbbm tr td .lbl.btn:hover {
                color: #FF8F19;
            }
            .txt.c1 {
                width: 100%;
                float: left;
            }
            .txt.num {
                text-align: right;
            }
            .tbbm td {
                margin: 0 -1px;
                padding: 0;
            }
            .tbbm td input[type="text"] {
                border-width: 1px;
                padding: 0px;
                margin: -1px;
                float: left;
            }
            .tbbm select {
                border-width: 1px;
                padding: 0px;
                margin: -1px;
            }
            .dbbs {
                width: 1740px;
            }
            .tbbs a {
                font-size: medium;
            }
            input[type="text"], input[type="button"] {
                font-size: medium;
            }
            .num {
                text-align: right;
            }
            select {
                font-size: medium;
            }
        </style>
    </head>
    <body ondragstart="return false" draggable="false"
    ondragenter="event.dataTransfer.dropEffect='none'; event.stopPropagation(); event.preventDefault();"
    ondragover="event.dataTransfer.dropEffect='none';event.stopPropagation(); event.preventDefault();"
    ondrop="event.dataTransfer.dropEffect='none';event.stopPropagation(); event.preventDefault();"
    >
        <div style="overflow: auto;display:block;">
            <!--#include file="../inc/toolbar.inc"-->
        </div>
        <div style="overflow: auto;display:block;width:1280px;">
            <div class="dview" id="dview">
                <table class="tview" id="tview" >
                    <tr>
                        <td align="center" style="width:20px; color:black;"><a id='vewChk'> </a></td>
                        <td align="center" style="width:80px; color:black;"><a id='vewDatea'> </a></td>
                        <td align="center" style="width:100px; color:black;"><a id='vewNoa'> </a></td>
                        <td align="center" style="width:80px; color:black;"><a id='vewNick'> </a></td>
                    </tr>
                    <tr>
                        <td >
                        <input id="chkBrow.*" type="checkbox" style=''/>
                        </td>
                        <td align="center" id='datea'>~datea</td>
                        <td align="center" id='noa'>~noa</td>
                        <td align="center" id='nick'>~nick</td>
                    </tr>
                </table>
            </div>
            <div class="dbbm">
                <table class="tbbm"  id="tbbm">
                    <tr style="height:1px;">
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td class="tdZ"></td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblType' class="lbl"> </a></td>
                        <td><select id="cmbTypea" class="txt c1"> </select></td>
                        <td><span> </span><a id='lblNoa' class="lbl"> </a></td>
                        <td colspan="2"><input id="txtNoa"   type="text" class="txt c1"/></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td class="tdZ"><input type="button" id="btnTip" value="?" style="float:right;" onclick="tipShow()"/></td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblDatea' class="lbl"> </a></td>
                        <td>
                        <input id="txtDatea" type="text" class="txt c1"/>
                        </td>
                        <td><span> </span><a id='lblMon' class="lbl"> </a></td>
                        <td>
                        <input id="txtMon" type="text" class="txt c1"/>
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblAcomp' class="lbl btn"> </a></td>
                        <td colspan="4">
                        <input id="txtCno" type="text" style="float:left;width:25%;"/>
                        <input id="txtAcomp" type="text" style="float:left;width:75%;"/>
                        </td>
                        <td><span> </span><a id='lblInvono' class="lbl btn"> </a></td>
                        <td colspan="2">
                        <input id="txtInvono" type="text" class="txt c1"/>
                        </td>
                    </tr>
                    <tr>
                        <td ><span> </span><a id="lblCust" class="lbl btn"> </a></td>
                        <td colspan="4">
                        <input id="txtCustno" type="text" style="float:left;width:25%;"/>
                        <input id="txtComp"  type="text" style="float:left;width:75%;"/>
                        <input id="txtNick"  type="text" style="display:none;"/>
                        </td>
                        <td><span> </span><a id='lblOrdeno' class="lbl btn"> </a></td>
                        <td colspan="2">
                        <input id="txtOrdeno" type="text" class="txt c1" />
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblTel' class="lbl"> </a></td>
                        <td colspan="4">
                        <input id="txtTel"  type="text"  class="txt c1"/>
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblAddr' class="lbl"> </a></td>
                        <td colspan="4" >
                        <input id="txtPost"  type="text" style="float:left; width:70px;"/>
                        <input id="txtAddr"  type="text" style="float:left; width:369px;"/>
                        </td>
                        <td><span> </span><a id='lblTrantype' class="lbl"> </a></td>
                        <td colspan="2"><select id="cmbTrantype" class="txt c1" name="D1" ></select></td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblAddr2' class="lbl"> </a></td>
                        <td colspan="4" >
                        <input id="txtPost2"  type="text" style="float:left; width:70px;"/>
                        <input id="txtAddr2"  type="text" style="float:left; width:347px;"/>
                        <select id="combAddr" style="width: 20px" onchange='combAddr_chg()'> </select>
                        </td>
                        <td><span> </span><a id='lblPaytype' class="lbl"> </a></td>
                        <td colspan="2">
                        <input id="txtPaytype" type="text" style="float:left; width:87%;"/>
                        <select id="combPaytype" style="float:left; width:26px;"></select>
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblMoney' class="lbl"> </a></td>
                        <td>
                        <input id="txtMoney" type="text" class="txt num c1" />
                        </td>
                        <td><span> </span><a id='lblTax' class="lbl"> </a></td>
                        <td>
                            <input id="txtTax" type="text" class="txt num c1 istax" />
                            <input id="txtVccatax" type="text" class="txt num c1 " style="display:none;" />
                        </td>
                        <td><span style="float:left;display:block;width:10px;"></span><select id="cmbTaxtype" style="float:left;width:80px;" ></select></td>
                        <td><span> </span><a id='lblTotal' class="lbl istax"> </a></td>
                        <td>
                        <input id="txtTotal" type="text" class="txt num c1 istax" />
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblMemo' class="lbl"> </a></td>
                        <td colspan="7">
                        <input id="txtMemo" type="text" class="txt c1"/>
                        </td>
                    </tr>
                    <tr>
                        <td><span> </span><a id='lblWorker' class="lbl"> </a></td>
                        <td>
                        <input id="txtWorker"  type="text" class="txt c1"/>
                        </td>
                        <td><span> </span><a id='lblWorker2' class="lbl"> </a></td>
                        <td>
                        <input id="txtWorker2"  type="text" class="txt c1"/>
                        </td>
                        <td></td>
                        <td><span> </span><a id="lblAccno" class="lbl btn"> </a></td>
                        <td>
                        <input id="txtAccno" type="text"  class="txt c1"/>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div class='dbbs'>
            <table id="tbbs" class='tbbs' style=' text-align:center'>
                <tr style='color:white; background:#003366;' >
                    <td  align="center" style="width:30px;">
                    <input class="btn"  id="btnPlus" type="button" value='+' style="font-weight: bold;"  />
                    </td>
                    <td align="center" style="width:20px;"></td>
                    <td align="center" style="width:120px;"><a id='lblProductno_st'> </a></td>
                    <td align="center" style="width:120px;"><a id='lblProduct_st'> </a></td>
                    <td align="center" style="width:30px;"><a id='lblUnit'></a></td>
                    <td align="center" style="width:80px;"><a id='lblMount_st'></a></td>
                    <td align="center" style="width:80px;"><a id='lblPrices_st'></a></td>
                    <td align="center" style="width:80px;"><a id='lblTotals_st'></td>
                    <td align="center" style="width:100px;"><a id='lblGweight_st'></a></td>
                    <td align="center" style="width:80px;"><a id='lblStore2_st'> </a></td>
                    <td align="center" style="width:180px;"><a id='lblMemos_st'></a></td>

                </tr>
                <tr  style='background:#cad3ff;'>
                    <td align="center">
                    <input class="btn"  id="btnMinus.*" type="button" value='-' style=" font-weight: bold;" />
                    <input id="txtNoq.*" type="text" style="display: none;" />
                    </td>
                    <td><a id="lblNo.*" style="font-weight: bold;text-align: center;display: block;"> </a></td>
                    <td>
                    <input class="btn"  id="btnProductno.*" type="button" value='.' style=" font-weight: bold;width:15px;float:left;" />
                    <input  id="txtProductno.*" type="text" style="width:85px;" />
                    <span style="display:block;width:15px;"> </span>
                    <td>
                    <input type="text" id="txtProduct.*" style="width:95%;" />
                    </td>
                    <!--上為虛擬下為實際-->
                    <input id="txtRadius.*" type="text" style="display:none;"/>
                    <input id="txtWidth.*" type="text" style="display:none;"/>
                    <input id="txtDime.*" type="text" style="display:none;"/>
                    <input id="txtLengthb.*" type="text" style="display:none;"/>
                    </td>
                    <td>
                    <input id="txtUnit.*" type="text" class="txt num" style="width:95%;text-align: center;"/>
                    </td>
                    <td>
                    <input id="txtMount.*" type="text" class="txt num" style="width:95%;"/>
                    </td>
                    <td>
                    <input id="txtWeight.*" type="text" class="txt num" style="width:95%;"/>
                    </td>
                    <td>
                    <input id="txtPrice.*" type="text"  class="txt num" style="width:95%;"/>
                    </td>
                    <td>
                    <input id="txtTotal.*" type="text" class="txt num" style="width:95%;"/>
                    </td>
                    <td>
                    <input id="txtGweight.*" type="text"  class="txt num" style="width:95%;"/>
                    </td>
                    <td>
                    <input id="txtMemo.*" type="text" class="txt" style="width:95%;"/>
                    <input id="recno.*" type="hidden" />
                    </td>

                </tr>
            </table>
        </div>
        <input id="q_sys" type="hidden" />
    </body>
</html>
