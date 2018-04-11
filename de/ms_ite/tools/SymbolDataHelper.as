package de.ms_ite.tools {
	
	public class SymbolDataHelper {
		
		public static var MAXLINK:int = 30;
		public static var MAXLEN:int = 30;
		
		public static function getTooltip( item:Object):String {
			
			var parts:Array = new Array();

//			var pattern:RegExp = /^http:[a-z0-9A-Z.\-_ ()\/äöüÄÖÜß%]+$/ig;
			var links:Array = new Array();
			var link:Array;
			
			for( var key:String in item) {
				var val:String = item[ key].toString();
				
				if ( ! isNaN(parseFloat( val)) && val == parseFloat( val).toString()) continue;
				if ( key.indexOf( 'mx_internal') == 0) continue;
			
//				trace( "ckk: "+key+" = "+val);
				
				var pattern:RegExp = /^http:[a-z0-9A-Z.\-_ ()\/äöüÄÖÜß%]+$/ig;
				if (( link = pattern.exec( val)) != null) {
//					trace( "link("+key+"): "+link.join( "#"));
					links.concat( link);
					continue;
				}
	
				if ( val.length > 24) val = val.substr( 0, 20)+" ...";
			
				parts.push( val);
			}
//			trace( "TOOLTIP: "+parts.join( ' - '));
			return parts.join( ' - ');
		}
		
		public static function textFromRow( item:Object):String {
			var temp:String = '';
			
			// for tooltipX: <br /> (with space) is translated to a separator, <br/> isn't!
			return '';
			
			if ( item.company.length) temp = '<b>'+item.company+'</b><br/>';
			
			var name:String = '';
	//		if ( item.tx_msitegis_firstname.length > 0) {
	//			if ( name.length > 0) name += ' ';
				if ( item.tx_msitegis_firstname != undefined) name += item.tx_msitegis_firstname;
	//		}
			if ( item.objektname.length > 0) {
				if ( name.length > 0) name += ' ';
				name += item.objektname;
	//			if ( name.length > 0) name += ' ';
			}
			if ( item.title.length > 0 && name.length > 0) name = item.title+"<br/>"+name;
					
			var adr:String = '';
			if ( item.strasse != undefined && item.strasse != '0') adr += item.strasse;
			if ( item.ort.length > 0 || item.plz.length > 0) {
				if ( adr.length > 0) adr += '<br/>';
				adr += (( item.plz != undefined) ? (item.plz+" ") : '')+(( item.ort != undefined) ? item.ort : '');
			}
	
			if ( name.length > 0 && adr.length > 0) name += "<br />";
			temp += name + adr;
			
	//		debug( "get textfromitem: "+temp);
	
			return temp;
		}
		
		public static function tooltipFromRow( item:Object):String {
			// get basic info
			var temp:String = textFromRow( item);
			
			return temp;
			// add extra info for tooltip
			
			// disabled for standard use
	//		temp += '<br /><a href="asfunction:'+this+'.addBasket,'+item.uid+'"><font color="#000000"><b><u>In die Merkliste</u></b></font></a>';
	
	//		temp += '<br /><img src="thumb.jpg">';
			
			if ( item.web.length > 0) {
				var str:String = item.web;
				if ( item.web.length > TTMAXLEN) {
					str = item.web.substring( 0, TTMAXLEN) + " ...";
				}
	//			temp += "web: <a href=\""+item.web+"\" target=\"_blank\"><u>"+str+"</u></a><br />";
//				temp += "<br /><a href=\"asfunction:"+this+".showURL,\" target=\"_blank\"><u>"+str+"</u></a>";
			}
			
			return temp;
		}
		
		public static function pageFromRow( item:Object, pmode:Boolean=false):String {
			var str:String;
			var temp:String = '';
	//		temp = "<a href=\"asfunction:_root.setInfo,"+this+"\">";
	
			if ( item.telefon.length > 0) temp += "tel: "+item.telefon + "<br />";
			if ( item.fax.length > 0) temp += "fax: "+item.fax+"<br />";
			if ( item.email.length > 0 && ( !pmode || item.email.length < MAXLINK)) {
				str = item.email;
				if ( item.email.length > MAXLEN && !pmode) {
					str = item.email.substring( 0, MAXLEN) + " ...";
				}
				temp += "email: <a href=\"mailto:"+item.email+"\"><u>"+str+"</u></a><br />";
			}
			if ( item.web.length > 0 && ( !pmode || item.web.length < MAXLINK)) {
				str = item.web;
				if ( item.web.length > MAXLEN && !pmode) {
					str = item.web.substring( 0, MAXLEN) + " ...";
				}
	//			temp += "web: <a href=\""+item.web+"\" target=\"_blank\"><u>"+str+"</u></a><br />";
//				temp += "web: <a href=\"asfunction:"+this+".showURL\"><u>"+str+"</u></a><br />";
			}
	
	//		if ( item.description.length > 0) temp += '<br />'+item.description;
			
			if ( temp.length > 0) temp = '<br />'+temp;
			return textFromRow( item)+temp;
		}
	}
}