package de.ms_ite.tools
{
	import flash.utils.*;
	
	import mx.collections.*;
	
	public class FormatCSV
	{
		protected static var SEP_LIST:Array = new Array( "\t", ';', ',', '|');
		protected static var READ_BLOCK:int = 128000;

		protected static var FIELD_DELIM:String = '"';
		
		public function FileFormatCSV():void {
		}

		protected static function wrapObject( obj:Object):ListCollectionView {
			var collection:ListCollectionView;
			
			if (obj is Array) {
				collection = new ArrayCollection( obj as Array);
			} else if (obj is IList) {
				collection = new ListCollectionView(IList(obj));
			} else if (obj is XMLList) {
				collection = new XMLListCollection(obj as XMLList);
			} else if (obj is XML) {
				var xl:XMLList = new XMLList();
				xl += obj;
				collection = new XMLListCollection(xl);
			} else {
				// convert it to an array containing this one item
				var tmp:Array = [];
				if (obj != null) tmp.push(obj);
				collection = new ArrayCollection(tmp);
			}
			
			return collection;
		}			
		
		public static function putCSV( txt:String, dpv:Object):Array {
			
			var dp:ListCollectionView = wrapObject( dpv);
			
			debug( "reading ...");
			
			var CSV_SEP:String = SEP_LIST[ 0];
			
			var colnames:Array = new Array();

			var prefix:String = '';
			
			dp.removeAll();			
			var linesRead:int = 0;
							
			var buffer:ByteArray = new ByteArray();
			buffer.writeMultiByte( txt, 'iso-8859-1');
			buffer.position = 0;

			var line:String = '';					
			var from:int = 0;

			for( var i:int=0; i < buffer.length; i++) {
				if ( buffer[ i] == 10 || buffer[ i] == 13) {
					if ( from != i) {
						line = prefix + buffer.readMultiByte( i - from, 'iso-8859-1');
						
						if ( linesRead == 0) CSV_SEP = readColumns( colnames, line);
						else pushLine( line, dp, colnames, CSV_SEP);
						
						linesRead++;
						prefix = '';
						line = '';
					}
					// read LF/CR
					buffer.readByte();
					from = i+1;
				}
			}
			if ( from < i) {
				prefix += buffer.readMultiByte( buffer.bytesAvailable, 'iso-8859-1');
			}
			if (( prefix+line).length > 0) {
				debug( "last line. "+prefix);
				if ( linesRead == 0) CSV_SEP = readColumns( colnames, prefix+line);
				else pushLine( prefix+line, dp, colnames, CSV_SEP);
				
				linesRead++;
			}
			
			
			return colnames;
		}
	
		protected static function pushLine( line:String, rows:ListCollectionView, colnames:Array, CSV_SEP:String):void {
/*			
			var rx:RegExp = /\"/g;
			line = line.replace( rx, '');
			line = line.toLowerCase();
*/			
			var cols:Array = line.split( CSV_SEP);
			
			var o:Object = new Object();
	
			var colname:String = '';
			var prefix:String = '';
			var k:int = 0;
			
			debug( "addRow: "+line.substr(0,20)+"...");
			
			for( var j:int=0; j < cols.length; j++) {
				var val:String = cols[ j];
				
				if ( val.indexOf( FIELD_DELIM) == 0) {
					// string starts with field delimiter
					
					debug( "0?("+prefix+"): "+val.lastIndexOf( FIELD_DELIM)+"/"+(val.length-1));
					if ( val.lastIndexOf( FIELD_DELIM) == val.length-1) {
						// delim@end: done
						setRowField( o, colnames[k++], prefix+val);
						prefix = '';
					} else {
						// no delim@end: save
						prefix += cols[j] + CSV_SEP;
					}
				} else {
					// no delim@start
					
					debug( "1?("+prefix+"): "+val.lastIndexOf( FIELD_DELIM)+"/"+(val.length-1));
					if ( prefix != '') {
						// we are in a field, wait for delim@end
						if ( val.lastIndexOf( FIELD_DELIM) == val.length-1) {
							// delim@end
							setRowField( o, colnames[k++], prefix+val);
							prefix = '';
						} else {
							// no delim@end
							prefix += cols[j] + CSV_SEP;
						}
					} else {
						// simply write value
						setRowField( o, colnames[k++], val);
						prefix = '';
					}
				}
			}
			rows.addItem( o);
		}
		
		protected static function setRowField( row:Object, prop:String, val:String):void {
			// deescape 
			debug( "val: "+val.substr(0,20));			
			if ( val.indexOf( FIELD_DELIM) == 0 && val.lastIndexOf( FIELD_DELIM) == val.length-1) {
				val = val.substring( 1, val.length-1);
			}
			var rx:RegExp = new RegExp( FIELD_DELIM+FIELD_DELIM, 'g');
			val = val.replace( rx, FIELD_DELIM);

			var matches:Array;
			var numFmt:RegExp = /^([+-]?\s*)(\d+)([\.,]?\d+)*/;
			if (( matches = val.match( numFmt)) != null) {
				
				if ( val.indexOf( '.') < val.indexOf( ',')) {
					// german
					var dotEx:RegExp = /\./g;
					val = val.replace( dotEx, '');
					val = val.replace( new RegExp( ',','g'), '.');
				} else {
					// us
					val = val.replace( new RegExp( ',','g'), '');
				}
				debug( "  col+: "+prop+" = '"+val+"' "+matches.join('#'));
				row[ prop] = parseFloat( val);
			} else {
//				debug( "  col-: "+prop+" = '"+val+"'");
				row[ prop] = val;
			}
		}
		
		protected static function readColumns( colnames:Array, line:String):String {
			var CSV_SEP:String = SEP_LIST[ 0];
			
			var rx:RegExp = /\"/g;
			line = line.replace( rx, '');
			line = line.toLowerCase();
			var cols:Array = line.split( CSV_SEP);
			
			if ( line.length == 0) return '';
							
			var i:int = 0;
			while ( cols.length == 1 && i < SEP_LIST.length) {
				CSV_SEP = SEP_LIST[ i];
				i++;
				cols = line.split( CSV_SEP);
			}
			debug( "using \""+CSV_SEP+"\" as separator.");

			for( i=0; i < cols.length; i++) {
				colnames.push( cols[i]);
			}
			
			return CSV_SEP;
		}
/*		
		public static function saveCSV( file:File, dpv:Object, colMap:Array, CSV_SEP:String):void {
			debug( "saving ...");
			
			var dp:ListCollectionView = wrapObject( dpv);
			
			var fileStream:FileStream = new FileStream();
			
			var buffer:ByteArray;
			
			fileStream.open(file, FileMode.WRITE);
			
			var data:Array = dp.toArray();

			var colNames:Array = new Array();
			for( var k:int=0; k < colMap.length; k++) {
				colNames.push( colMap[k].header);
			}
			fileStream.writeMultiByte( colNames.join( CSV_SEP) + "\n", 'iso-8859-1');
						
			for( var i:int=0; i < data.length; i++) {
				var line:Array = new Array();
				
				for( var k:int=0; k < colMap.length; k++) {
					line.push( FIELD_DELIM+data[i][colMap[k].data]+FIELD_DELIM);
					debug( "  line: "+String( data[i][colMap[k].data]).substr(0,20)+"...");
				}

				fileStream.writeMultiByte( line.join( CSV_SEP) + "\n", 'iso-8859-1');
			}
			
			fileStream.close();
		}
*/		
		public static function getCSV( dpv:Object, colMap:Array, CSV_SEP:String):String {
			debug( "storing ...");
			var k:int;
			var buffer:String = '';
			var dp:ListCollectionView = wrapObject( dpv);			
			var data:Array = dp.toArray();

			var colNames:Array = new Array();
			for( k = 0; k < colMap.length; k++) {
				colNames.push( colMap[k].header);
			}
			buffer +=  colNames.join( CSV_SEP) + "\n";
						
			for( var i:int=0; i < data.length; i++) {
				var line:Array = new Array();
				
				for( k = 0; k < colMap.length; k++) {
					line.push( FIELD_DELIM+data[i][colMap[k].data]+FIELD_DELIM);
//					debug( "  line: "+String( data[i][colMap[k].data]).substr(0,20)+"...");
				}

				buffer += line.join( CSV_SEP) + "\n";
			}
			
			return buffer;
		}

		protected static function debug( txt:String):void {
//			trace( "DBG CSV: "+txt);
		}
	}
}