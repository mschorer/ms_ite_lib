package de.ms_ite.components {
	import de.ms_ite.*;
	import de.ms_ite.events.TableSheetEvent;
	import de.ms_ite.maptech.*;
	import de.ms_ite.maptech.containers.*;
	import de.ms_ite.maptech.layers.*;
	import de.ms_ite.maptech.symbols.*;
	import de.ms_ite.maptech.symbols.styles.*;
	import de.ms_ite.tools.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.containers.*;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.Menu;
	import mx.controls.dataGridClasses.*;
	import mx.controls.listClasses.*;
	import mx.events.*;
	import mx.managers.PopUpManager;

	public class TableSheet extends Canvas {
		
		protected var _stack:TableSheetStack;
		
		public var layer:CompatLayer;
		public var table:DataGrid;
		public var _dataProvider:ListCollectionView = null;
		protected var symbolStyle:SymbolStyle;
		
		protected var _map:Lighttable;

		protected var ctxZoomRow:ContextMenuItem;
		protected var ctxAddRow:ContextMenuItem;
		protected var ctxDelRow:ContextMenuItem;
		protected var ctxAddCol:ContextMenuItem;
		protected var ctxDelCol:ContextMenuItem;
		protected var ctxRenCol:ContextMenuItem;
		protected var ctxZoomSheet:ContextMenuItem;
		protected var ctxClearSheet:ContextMenuItem;
		protected var ctxPaste:ContextMenuItem;
		
		protected var ctxMouseTarget:Object;
		
		protected var delColumnName:String;
		
		protected var renameDialog:RenamePanel;
		
		public var hasItems:Boolean;
		
		public function TableSheet( stack:TableSheetStack, st:SymbolStyle=null) {
			this.stack = stack;
			_dataProvider = null;
			symbolStyle = ( st == null) ? (new SymbolStyle()) : st;
			hasItems = false;
			
			dataProvider = new ArrayCollection();			
		}

        private function debug( txt:String):void {
        	trace("DBG TSHEET: "+txt);
        }        

		public function set stack( ts:TableSheetStack):void {
			_stack = ts;
		}	
		
		public function get stack():TableSheetStack {
			return _stack;
		}
		
		public function set dataProvider( dp:ListCollectionView):void {
			if ( _dataProvider != null) _dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleDPChange);

			_dataProvider = dp;
			_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleDPChange);
			handleDPChange( null);
			
			if ( table != null) table.dataProvider = _dataProvider;
			if ( layer != null) layer.dataProvider = _dataProvider;
		}		

		public function get dataProvider():ListCollectionView {
			return _dataProvider;
		}
				
		override protected function createChildren():void {
			debug( "createChildren");
			setupUI();
		}
		
		public function setupUI():void {
			layer = new CompatLayer( symbolStyle);
			layer.dataProvider = dataProvider;
			
			if ( _map != null) _map.addChild( layer);
			
	    	layer.addEventListener( Event.SELECT, handleSymbolClick);
	    	layer.addEventListener( Event.CHANGE, handleSymbolSelectionChange);
	    	
	    	if ( _dataProvider != null) layer.dataProvider = _dataProvider;

			table = new DataGrid();
			table.allowMultipleSelection = true;
			table.setStyle( 'alternatingColors', "[#66FFFF, #33CCCC]");
			table.dropEnabled = true;
			table.addEventListener( DragEvent.DRAG_DROP, dragDropHandler);
	    	if ( _dataProvider != null) table.dataProvider = _dataProvider;

			var temp:ContextMenu = new ContextMenu();
			temp.hideBuiltInItems();
			
			ctxZoomRow = new ContextMenuItem( 'zoom to row');
			ctxZoomRow.enabled = false;
			ctxZoomRow.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleRowZoom);

			ctxAddRow = new ContextMenuItem( 'add row');
			ctxAddRow.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleRowAdd);
			
			ctxDelRow = new ContextMenuItem( 'del row');
			ctxDelRow.enabled = false;
			ctxDelRow.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleRowDel);

			ctxAddCol = new ContextMenuItem( 'add column');
			ctxAddCol.separatorBefore = true;
			ctxAddCol.enabled = false;
			ctxAddCol.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleColAdd);
			
			ctxDelCol = new ContextMenuItem( 'del column');
			ctxDelCol.enabled = false;
			ctxDelCol.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleColDel);

			ctxRenCol = new ContextMenuItem( 'rename column');
			ctxRenCol.enabled = false;
			ctxRenCol.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleColRen);

			ctxZoomSheet = new ContextMenuItem( 'zoom to sheet');
			ctxZoomSheet.separatorBefore = true;
			ctxZoomSheet.enabled = false;
			ctxZoomSheet.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleZoomSheet);

			ctxClearSheet = new ContextMenuItem( 'clear sheet');
			ctxClearSheet.enabled = false;
			ctxClearSheet.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handleClearSheet);

			ctxPaste = new ContextMenuItem( 'paste clipboard');
			ctxPaste.enabled = true;
			ctxPaste.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, handlePaste);

			temp.customItems = [ ctxZoomRow, ctxAddRow, ctxDelRow, ctxAddCol, ctxDelCol, ctxRenCol, ctxZoomSheet, ctxClearSheet, ctxPaste];
			temp.addEventListener( ContextMenuEvent.MENU_SELECT, handleContextOpen);

			table.contextMenu = temp;
			
			table.editable = true;
			table.doubleClickEnabled = true;
			table.percentWidth=100;
			table.percentHeight=100;
			addChild( table);
			table.dataProvider = dataProvider;
	    	table.addEventListener( ListEvent.CHANGE, handleSelectionChange);		   

			// events to end edit mode
			table.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyDown);
			table.addEventListener( MouseEvent.CLICK, handleClick);
			// event to start edit mode
			table.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, handleItemDoubleClick); 			
		}
		
		private function dragDropHandler(event:DragEvent):void {
			debug( "dragdrop to sheet");
			if (event.dragSource.hasFormat("items")) {
				// Explicitly handle the dragDrop event.            
				event.preventDefault();
				event.currentTarget.hideDropFeedback(event);
				
				// Get drop target.
				var dropTarget:DataGrid = DataGrid(event.currentTarget);
				
				var itemsArray:Array = event.dragSource.dataForFormat('items') as Array;
				// Get the drop location in the destination.
				var dropLoc:int = dropTarget.calculateDropIndex(event);
				
				for( var i:int=0; i < itemsArray.length; i++) {
					IList( dropTarget.dataProvider).addItemAt( itemsArray[i], dropLoc+i);
				}
			}
		}
            
        protected function handleDPChange( evt:Event):void {
//        	debug( "dp change: "+evt);
        	
        	var temp:Boolean = ( _dataProvider == null) ? false : (dataProvider.length > 0);
        	
        	if ( ctxAddCol != null) {
//				ctxDelRow.enabled = 
				ctxAddCol.enabled = ctxZoomSheet.enabled = ctxClearSheet.enabled = temp;
        	}
        	
			if ( temp) toolTip = 'Use right-click/context menu to work on rows/columns.';
			else toolTip = 'Drop a CSV-file here.';
			
			if ( hasItems != temp) {
				hasItems = temp;
				dispatchEvent( new Event( Event.CHANGE));
			}
		}
		
	    protected function handleSymbolSelectionChange( evt:Event):void {
	    	debug( "selection changed: #"+layer.selectedItems.length);
	    	table.selectedItems = layer.selectedItems;
	    	
	    	if ( table.selectedItems.length > 0) {
		    	var item:Object = layer.selectedItems[ table.selectedItems.length -1];
	
				// find index of last added item
				var idx:int = -1;	    	
		    	for( var i:int = 0; i < table.selectedIndices.length; i++) {
		    		if ( table.dataProvider[ table.selectedIndices[ i]] == item) {
		    			idx = table.selectedIndices[ i];
		    			break;
		    		}
		    	}
		    	
		    	// if not visible scroll table to show it
		    	if ( ! table.isItemVisible( item) && idx >= 0) {
		    		table.scrollToIndex( idx);
		    	}
	    	}
//	    	dispatchEvent( new Event( Event.CHANGE));
	    }
		    
	    protected function handleSymbolClick( evt:Event):void {
	    	debug( "click");
	    	var item:Object = layer.selectedItems[0];
	    	
	    	if ( ! table.isItemVisible( item)) {
	    		table.scrollToIndex( table.selectedIndices[0]);
	    	}
	    	
	    	dispatchEvent( new Event( Event.SELECT));
	    }
		    
		protected function handleContextOpen( evt:ContextMenuEvent):void {
			debug( "context open "+evt.mouseTarget);
			
			ctxMouseTarget = evt.mouseTarget;
			
			if ( ctxMouseTarget != null) {
				var parent:Object = ctxMouseTarget.parent;

				var headerClicked:Boolean = ( ctxMouseTarget is DataGridItemRenderer && parent is DataGridHeader) 
				ctxDelCol.enabled = headerClicked;
				ctxRenCol.enabled = headerClicked;

				var rowClicked:Boolean = ( ctxMouseTarget is IListItemRenderer && parent is ListBaseContentHolder);
				ctxZoomRow.enabled = rowClicked;
				ctxDelRow.enabled = rowClicked;
			}
		}
		
		protected function handleColAdd( evt:ContextMenuEvent):void {
			var tempcol:String = addColumn();
			askColumnRename( tempcol);
		}

		protected function handleColDel( evt:ContextMenuEvent):void {
			// use saved mouseTarget
			var col:Object = (evt.mouseTarget != null) ? evt.mouseTarget : ctxMouseTarget;

			var parent:Object = col.parent;
			
			if ( col is DataGridItemRenderer && parent is DataGridHeader) {
				var colname:String = DataGridItemRenderer( col).text;
				debug( "column clicked @ "+colname);
				askColumnDel( colname);
			}
		}
		
		protected function handleColRen( evt:ContextMenuEvent):void {
			// use saved mouseTarget
			var col:Object = (evt.mouseTarget != null) ? evt.mouseTarget : ctxMouseTarget;
			
			if ( col != null && col is DataGridItemRenderer && col.parent is DataGridHeader) {
				var colname:String = DataGridItemRenderer( col).text;
				debug( "column clicked @ "+colname);
				askColumnRename( colname);
			}
		}
		
		protected function handleZoomSheet( evt:ContextMenuEvent):void {
			dispatchEvent( new TableSheetEvent( TableSheetEvent.TS_ZOOM_ALL));
		}

		protected function handleRowZoom( evt:ContextMenuEvent):void {
			var row:Object = (evt.mouseTarget != null) ? evt.mouseTarget : ctxMouseTarget;

			var temp:int;
			if ( row is IListItemRenderer) temp = table.itemRendererToIndex( row as IListItemRenderer);
			else temp = -1;
			
			if ( temp >= 0) {
				var nevt:TableSheetEvent = new TableSheetEvent( TableSheetEvent.TS_ZOOM_ITEM);
				nevt.item = dataProvider.getItemAt(temp);
				nevt.index = temp;
				
				dispatchEvent( nevt);
			}
		}
		
		protected function handleRowAdd( evt:ContextMenuEvent):void {
			var row:Object = (evt.mouseTarget != null) ? evt.mouseTarget : ctxMouseTarget;

			var temp:int;
			if ( row is IListItemRenderer) temp = table.itemRendererToIndex( row as IListItemRenderer);
			else temp = -1;
			debug( "add: @ "+temp+" / "+row);

			// insert after
			addRow( temp+1);
		}
		
		protected function handleRowDel( evt:ContextMenuEvent):void {
			if ( dataProvider.length == 0) return;
			
			var row:Object = (evt.mouseTarget != null) ? evt.mouseTarget : ctxMouseTarget;

			if ( row is IListItemRenderer) {
				var temp:int = table.itemRendererToIndex( row as IListItemRenderer);
				debug( "del: "+temp);
				delRow( temp);
			}
		}

		protected function handleClearSheet( evt:ContextMenuEvent):void {
			dataProvider.removeAll();
		}

		protected function handleRowFunction( evt:MenuEvent):void {
			debug( "menu: "+evt.label);
			switch( evt.label) {
				case 'add row': addRow( table.selectedIndex);
				break;
				
				case 'del row': delRow( table.selectedIndex);
				break;
				
				default:
				}
		}

		protected function addRow( index:int):void {
			if ( dataProvider.length == 0) dataProvider.addItem( {name:'', location:'POINT( 0 0)'});
			else {
				var item:Object = cloneEmpty( dataProvider.getItemAt(0));
				dataProvider.addItemAt( item, index);
			}
			dispatchEvent( new Event( Event.CHANGE));
		}
		
		protected function delRow( index:int):void {
			if ( 0 <= index && index < dataProvider.length) dataProvider.removeItemAt( index);
			dispatchEvent( new Event( Event.CHANGE));
		}	
		
		private function handleSelectionChange( event:ListEvent):void {
	    	debug( "selection changed: #"+table.selectedItems.length);
//            if ( event.rowIndex >= 0) layer.selectItem( dataProvider[ event.rowIndex]);
            layer.selectedItems = table.selectedItems;
        }
  
  		// a single click disabled editing      
		private function handleClick( event:MouseEvent):void {
//	    	debug( "down "+event.target);
	    	table.editable = false;
		}
		
		// leving with ESC disables editmode
		protected function handleKeyDown( evt:KeyboardEvent):void {
//			debug( "keyboard "+evt.keyCode);
			if ( evt.keyCode == Keyboard.ESCAPE) table.editable = false;
			
			if ( evt.ctrlKey == true && evt.charCode == 'v'.charCodeAt( 0)) {
				_stack.pasteClipboard( this);
			}
		}

		// enable and start editing when double-clicked
		protected function handleItemDoubleClick( evt:ListEvent):void {
			debug( "dbl clicked @ "+evt.columnIndex+"/"+evt.rowIndex);
			table.editable = true;
			table.editedItemPosition = {columnIndex:evt.columnIndex, rowIndex:evt.rowIndex};
		}
		
		public function set symbolClass( c:Class):void {
//			layer.symbolClass = c;
		}
		
		public function get symbolClass():Class {
//			return layer.symbolClass;
			return null;
		}
		
		public function set style( st:SymbolStyle):void {
			layer.style = st;
			symbolStyle = st;
		}
		
		public function get style():SymbolStyle {
			return symbolStyle;
		}		

		public function set map( map:Lighttable):void {
			debug( "set map: "+map);
			if ( map == null && layer != null) _map.removeChild( layer);
			_map = map;

			if ( layer != null && map != null) map.addChild( layer);
		}
		
		public function get map():Lighttable {
			return _map;
		}
		
		public function get columnNames():Array {
			var cn:Array = new Array();
			
			var cols:Array = table.columns;
			for( var i:int=0; i < cols.length; i++) {
				cn.push( {header:cols[i].headerText, data:cols[i].dataField});
			}
			
			return cn;
		}
		
		private function hideShowColumns( evt:MenuEvent):void  {
			debug( "menu_changed: "+evt.index+"/"+evt.label+" / "+evt.item.toggled);

			var aColumns:Array = table.columns;

			var dgc:DataGridColumn;
			var sDataField:String;
			var sDataFieldCur:String;
			var bFound:Boolean

			for (var i:int=0; i < aColumns.length; i++)  {
				dgc = aColumns[i];
				if ( dgc.headerText == evt.label) dgc.visible = evt.item.toggled;
			}
			spaceEqually();
		}
		
		public function addColumn( colname:String = 'col_'):String {
			
			var cols:Array = table.columns;

			var notUnique:Boolean = true;
			var j:int = 0;
			var i:int;
			var tempname:String = colname;
			while( notUnique) {
				notUnique = false;
				for( i =0; i < cols.length; i++) {
					if ( cols[i].dataField == tempname || cols[i].headerText == tempname) {
						notUnique = true;
						break;
					}
				}
				if ( ! notUnique) break;
				tempname = colname+j;
				j++;
			}
			debug( "created unique dataField: "+tempname);
			
			var col:DataGridColumn = new DataGridColumn();
			col.headerText = tempname;
			col.dataField = tempname;
			
			cols.push( col);
			table.columns = cols;
			
			for( i = 0; i < dataProvider.length; i++) {
				var temp:Object = dataProvider.getItemAt( i);
				if ( ! temp.hasOwnProperty( tempname)) temp[ tempname] = '';
				dataProvider.itemUpdated( temp, tempname, '', '');
			}
			
			return tempname;
		}

		protected function askColumnDel( cname:String):void {
			delColumnName = cname;
			Alert.show( 'Are you sure to delete column "'+cname+'" ?', 'Delete column?', Alert.OK | Alert.CANCEL, this, delColumnOk);
		}
		
		protected function delColumnOk( evt:CloseEvent):void {
			trace( "dle: "+evt.toString());
			if ( evt.detail == Alert.OK) {
				delColumn( delColumnName);
			}
		}
		
		protected function delColumn( cname:String):void {
			var cols:Array = table.columns;
			var i:int = 0;
			while( i < cols.length) {
				if ( cols[i].headerText == cname) cols.splice( i, 1);
				else i++;
			}
			table.columns = cols;
			dispatchEvent( new Event( Event.CHANGE));
		}
		
		protected function askColumnRename( cname:String):void {
			var cols:Array = table.columns;
			var i:int = 0;
			while( i < cols.length) {
				if ( cols[i].headerText == cname) {
					renameDialog = RenamePanel( PopUpManager.createPopUp( this, RenamePanel, true));
					PopUpManager.centerPopUp( renameDialog);
					renameDialog.addEventListener( CloseEvent.CLOSE, handleRenameDone);
					renameDialog.visible = true;
					renameDialog.column = cols[i];
					renameDialog.text = cname;
					break;
				}
				i++;
			}			
		}
		
		protected function handleRenameDone( evt:CloseEvent):void {
			trace( "dle: "+evt.toString());
			if ( evt.detail == Alert.OK) {
				debug( renameDialog.column+" -> "+renameDialog.text);
				renameColumn( renameDialog.column, renameDialog.text);
			}
			if ( evt.target == renameDialog) {
				PopUpManager.removePopUp( renameDialog);
			}
		}
		
		protected function renameColumn( dgc:DataGridColumn, label:String):void {
			var cols:Array = table.columns;
			var i:int = 0;
			while( i < cols.length) {
				if ( cols[i] == dgc) {
					dgc.headerText = label;
					break;
				}
				i++;
			}
			dispatchEvent( new Event( Event.CHANGE));
		}
		
		public function toggleColumnDialog( parent:DisplayObjectContainer, x:int, y:int):void {
			
			var activeColumns:Array = table.columns;

			var cols:Array = new Array();
			var dgc:DataGridColumn;

			for (var i:int=0; i < activeColumns.length; i++)  {
				dgc = activeColumns[i];
				
				var temp:Object = new Object();
				temp.label = dgc.headerText;
				temp.type = 'check';
				temp.toggled = dgc.visible;
				
				cols.push( temp);
			}

			var menu:Menu = Menu.createMenu( parent, cols, true);
			menu.addEventListener( MenuEvent.ITEM_CLICK, hideShowColumns);
			
			menu.show();
			menu.move( x, y);				
		}			

		public function spaceEqually():void {
			var cols:Array = table.columns;
			var colcount:int = cols.length;
			var vis:int = 0;
			
			for( var j:int = 0; j < colcount; j++) {
				if ( cols[j].visible) vis++;
			}				

			debug( "columns visible: "+vis+" of "+cols.length);
			
			var cwd:int = Math.round( parent.width / vis);
			debug( "resizing to: "+cwd);
			
			for( j = 0; j < colcount; j++) {
				if ( cols[ j].visible) cols[j].width = cwd;
			}				
		}

	    public function stripColumns():void {
	    	
	    	if ( dataProvider.length == 0) {
	    		table.columns = new Array();
	    		return;
	    	}
	    	
	    	var col:DataGridColumn;
	    	var row:Object = dataProvider[0];
			var cols:Array = new Array();
			var k:int = 0;
			
			if ( row is Array) {
				for( var j:int = 0; j < row.length; j++) {
					if ( row[ j].indexOf( 'mx_internal') == 0) continue;
					debug( "adding col: "+j);
					
					col = new DataGridColumn();
					col.headerText = row[ j];
					col.dataField = row[ j];
					col.visible = k < 10;
					cols.push(col);
					k++;
				}					
			} else {
				for( var s:String in row) {
					if ( s.indexOf( 'mx_internal') == 0) continue;
					debug( "adding col: "+s);

					col = new DataGridColumn();
					col.headerText = s;
					col.dataField = s;
					col.visible = k < 10;
					cols.push(col);
					k++;
				}
				cols.sortOn( 'headerText');
			}
			table.columns = cols;
			spaceEqually();
	    }
					    
	    public function columnsMatch( data:Array):Boolean {
	    	
	    	if ( dataProvider == null || dataProvider.length == 0) {
	    		return true;
	    	}
	    	
	    	var row:Object = dataProvider[0];
	    	var matched:Boolean = true;
			
			for( var s:String in data[0]) {
				debug( "checking: "+s+".");
				if ( ! row.hasOwnProperty( s)) {
					debug( "  kicked: "+s+".");
					matched = false;
					break;
				}
			}
			
			return matched;
	    }
	    
	    public function cloneEmpty( row:Object):Object {

			var temp:Object = null;
				    	
	    	if ( row == null) return temp;
	    	
	    	var myBA:ByteArray = new ByteArray();
			myBA.writeObject( row);
			myBA.position = 0;
		    temp = myBA.readObject();
			    
			for( var s:String in row) {
				debug( "resetting: "+s+".");
				temp[s] = '';
			}
			
			return temp;
	    }

	    public function addData( dp:Array):void {
    		for( var i:int=0; i < dp.length; i++) {
    			dataProvider.addItem( dp[i]);            			
    		}
	    }
	    
	    public function setData( dp:Array):void {
	    	dataProvider = new ArrayCollection( dp);
	    }
	    
	    public function zoomItem( item:Object):void {
			var view:Bounds = _map.viewport;

			var bounds:Bounds = layer.getSymbol( item).getMBR();
			debug( "zoom to "+item+" @ "+bounds);
			
			if ( ! bounds.isValid()) return;
			
			// do nothing if completely inside
//				if ( bounds.isWithinCoord( view.left, view.bottom) && bounds.isWithinCoord( view.right, view.top)) return;
			
			debug( "view: "+bounds);
			bounds = bounds.getExpandedPx( bounds.width / 10, bounds.height / 10);
			bounds.clip( _map.bounds);
			
			debug( "view: "+bounds);
			if ( bounds.left != 0 || bounds.right != 0 || bounds.top != 0 || bounds.bottom != 0) {
				_map.viewport = bounds;
			} else {
				debug( "no significant data.");
			}	    	
	    }
					    
	    public function zoom():void {
	    	
			var view:Bounds = _map.viewport;

			var bounds:Bounds = layer.bounds;
			debug( "zoom to "+bounds);
			if ( ! bounds.isValid()) return;
			
			// do nothing if completely inside
//				if ( bounds.isWithinCoord( view.left, view.bottom) && bounds.isWithinCoord( view.right, view.top)) return;
			
			debug( "view: "+bounds);
			bounds = bounds.getExpandedPx( bounds.width / 10, bounds.height / 10);
			bounds.clip( _map.bounds);
			
			debug( "view: "+bounds);
			if ( bounds.left != 0 || bounds.right != 0 || bounds.top != 0 || bounds.bottom != 0) {
				_map.viewport = bounds;
			} else {
				debug( "no significant data.");
			}
	    }
	    
	    protected function handlePaste( evt:ContextMenuEvent):void {
	    	_stack.pasteClipboard( this); 
	    }
        
        protected function wrapCDATA( txt:String):XML {
        	return new XML( '<![CDATA['+txt+']]>');
        }
        
     	public function toXML():XML  {
			var temp:XML = <sheet></sheet>
			temp.appendChild( symbolStyle.toXML());
			var data:XML = <data>{wrapCDATA(FormatCSV.getCSV( _dataProvider, columnNames, ';'))}</data>
			temp.appendChild( data);
			
			return temp;
		}

     	public function fromXML( xml:XML):void  {
			
			symbolStyle.fromXML( xml.style);			
			var csv:String = xml.data;
			
			FormatCSV.putCSV( csv, _dataProvider);
     	}

       	public function toData( buffer:ByteArray):XML  {
			var temp:XML = <sheet></sheet>
			temp.appendChild( symbolStyle.toXML());
			var data:XML = <data></data>

			data.@offset = buffer.length;
			Object( stack).csvLoader.writeBuffer( buffer, _dataProvider, columnNames, ';');
			data.@size = (buffer.length - data.@offset);
			debug( "    wrote raw: "+data.@size+" @ "+data.@offset);			
			
			temp.appendChild( data);
			
			return temp;
		}

     	public function fromData( xml:XML, buffer:ByteArray, base:int):void  {
			
			symbolStyle.fromXML( xml.style);			
			var offset:int = base + parseInt( xml.data.@offset);
			var size:int = parseInt( xml.data.@size);
			debug( "    read raw: "+size+" @ "+offset);
			
			Object( stack).csvLoader.loadBuffer( _dataProvider, buffer, offset, size);
     	}
	}
}