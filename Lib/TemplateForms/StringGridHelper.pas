unit StringGridHelper;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  FMX.Grid, FMX.Types;

type
  /// <summary>
  /// Class helper for TStringGrid to provide JSON import/export functionality
  /// </summary>
  TStringGridHelper = class helper for TStringGrid
  public
    /// <summary>
    /// Exports all grid data to JSON format
    /// Returns a JSON object containing columns definition and rows data
    /// </summary>
    function SaveToJSON: string;

    /// <summary>
    /// Imports grid data from JSON format
    /// Clears existing data and loads from JSON object
    /// Returns True if successful, False otherwise
    /// </summary>
    function LoadFromJSON(const AJSON: string): Boolean;

    /// <summary>
    /// Clears all data from the grid
    /// </summary>
    procedure ClearGrid;


    /// <summary>
    /// StringGrid'e belirtilen sayýda satýr ve sütun ekler
    /// </summary>
    /// <param name="ARowCount">Eklenecek satýr sayýsý</param>
    /// <param name="AColumnCount">Eklenecek sütun sayýsý</param>
    /// <param name="ADefaultColumnWidth">Varsayýlan sütun geniþliði (opsiyonel, default: 100)</param>
    procedure AddRowsAndColumns(ARowCount, AColumnCount: Integer;
      ADefaultColumnWidth: Single = 100);

    /// <summary>
    /// StringGrid'e sadece satýr ekler
    /// </summary>
    procedure AddRows(ARowCount: Integer);

    /// <summary>
    /// StringGrid'e sadece sütun ekler
    /// </summary>
    procedure AddColumns(AColumnCount: Integer; ADefaultWidth: Single = 100);

    /// <summary>
    /// StringGrid'i temizler ve yeni boyutlandýrýr
    /// </summary>
    procedure SetupGrid(ARowCount, AColumnCount: Integer;
      ADefaultColumnWidth: Single = 100);

    /// <summary>
    /// Belirtilen sütuna baþlýk atar
    /// </summary>
    procedure SetColumnHeader(AColumnIndex: Integer; const AHeader: string);

    /// <summary>
    /// Tüm sütunlara baþlýk atar
    /// </summary>
    procedure SetColumnHeaders(const AHeaders: array of string);


  end;

implementation

{ TStringGridHelper }

function TStringGridHelper.SaveToJSON: string;
var
  JSONObj: TJSONObject;
  JSONColumns: TJSONArray;
  JSONRows: TJSONArray;
  JSONRow: TJSONArray;
  JSONCol: TJSONObject;
  Col, Row: Integer;
  CellValue: string;
begin
  Result := '{}';
  JSONObj := TJSONObject.Create;
  try
    try
      // Save column information
      JSONColumns := TJSONArray.Create;
      for Col := 0 to Self.ColumnCount - 1 do
      begin
        JSONCol := TJSONObject.Create;
        JSONCol.AddPair('index', TJSONNumber.Create(Col));
        JSONCol.AddPair('header', Self.Columns[Col].Header);
        JSONCol.AddPair('width', TJSONNumber.Create(Self.Columns[Col].Width));
        JSONColumns.AddElement(JSONCol);
      end;
      JSONObj.AddPair('columns', JSONColumns);
      
      // Save row data
      JSONRows := TJSONArray.Create;
      for Row := 0 to Self.RowCount - 1 do
      begin
        JSONRow := TJSONArray.Create;
        for Col := 0 to Self.ColumnCount - 1 do
        begin
          CellValue := Self.Cells[Col, Row];
          JSONRow.AddElement(TJSONString.Create(CellValue));
        end;
        JSONRows.AddElement(JSONRow);
      end;
      JSONObj.AddPair('rows', JSONRows);
      
      // Save grid properties
      JSONObj.AddPair('rowCount', TJSONNumber.Create(Self.RowCount));
      JSONObj.AddPair('columnCount', TJSONNumber.Create(Self.ColumnCount));
      
      Result := JSONObj.ToString;
    except
      on E: Exception do
      begin
        // Silent exception handling - return empty object
        Result := '{}';
      end;
    end;
  finally
    JSONObj.Free;
  end;
end;

function TStringGridHelper.LoadFromJSON(const AJSON: string): Boolean;
var
  JSONObj: TJSONObject;
  JSONValue: TJSONValue;
  JSONColumns: TJSONArray;
  JSONRows: TJSONArray;
  JSONRow: TJSONArray;
  JSONCol: TJSONObject;
  Col, Row: Integer;
  RowCount, ColumnCount: Integer;
  CellValue: string;
  ColHeader: string;
  ColWidth: Double;
begin
  Result := False;
  
  if Trim(AJSON) = '' then
    Exit;
    
  try
    try
      JSONValue := TJSONObject.ParseJSONValue(AJSON);
      if JSONValue = nil then
        Exit;
        
      if not (JSONValue is TJSONObject) then
      begin
        JSONValue.Free;
        Exit;
      end;
      
      JSONObj := JSONValue as TJSONObject;
      try
        // Get grid dimensions
        if not JSONObj.TryGetValue<Integer>('rowCount', RowCount) then
          RowCount := 0;
        if not JSONObj.TryGetValue<Integer>('columnCount', ColumnCount) then
          ColumnCount := 0;
          
        // Set grid dimensions
        if ColumnCount > 0 then
           self.AddColumns( ColumnCount);
        if RowCount > 0 then
          Self.RowCount := RowCount;

        // Load column information
        if JSONObj.TryGetValue<TJSONArray>('columns', JSONColumns) then
        begin
          for Col := 0 to JSONColumns.Count - 1 do
          begin
            if JSONColumns.Items[Col] is TJSONObject then
            begin
              JSONCol := JSONColumns.Items[Col] as TJSONObject;
              
              if Col < Self.ColumnCount then
              begin
                // Set column header
                if JSONCol.TryGetValue<string>('header', ColHeader) then
                  Self.Columns[Col].Header := ColHeader;
                  
                // Set column width
                if JSONCol.TryGetValue<Double>('width', ColWidth) then
                  Self.Columns[Col].Width := ColWidth;
              end;
            end;
          end;
        end;
        
        // Load row data
        if JSONObj.TryGetValue<TJSONArray>('rows', JSONRows) then
        begin
          for Row := 0 to JSONRows.Count - 1 do
          begin
            if (JSONRows.Items[Row] is TJSONArray) and (Row < Self.RowCount) then
            begin
              JSONRow := JSONRows.Items[Row] as TJSONArray;
              for Col := 0 to JSONRow.Count - 1 do
              begin
                if Col < Self.ColumnCount then
                begin
                  if JSONRow.Items[Col] is TJSONString then
                    CellValue := JSONRow.Items[Col].Value
                  else
                    CellValue := JSONRow.Items[Col].ToString;
                    
                  Self.Cells[Col, Row] := CellValue;
                end;
              end;
            end;
          end;
        end;
        
        Result := True;
      finally
        JSONObj.Free;
      end;
    except
      on E: Exception do
      begin
        // Silent exception handling
        Result := False;
      end;
    end;
  except
    Result := False;
  end;
end;

procedure TStringGridHelper.ClearGrid;
var
  Col, Row: Integer;
begin
  try
    // Clear all cells
    for Row := 0 to Self.RowCount - 1 do
    begin
      for Col := 0 to Self.ColumnCount - 1 do
      begin
        Self.Cells[Col, Row] := '';
      end;
    end;
  except
    // Silent exception handling
  end;
end;


procedure TStringGridHelper.AddRowsAndColumns(ARowCount, AColumnCount: Integer;
  ADefaultColumnWidth: Single = 100);
var
  I: Integer;
  Column: TColumn;
begin
  // Önce sütunlarý ekle
  for I := 1 to AColumnCount do
  begin
    Column := TStringColumn.Create(Self);
    Column.Parent := Self;
    Column.Width := ADefaultColumnWidth;
    Column.Header := 'Column ' + IntToStr(Self.ColumnCount);
  end;

  // Sonra satýrlarý ekle
  Self.RowCount := Self.RowCount + ARowCount;
end;

procedure TStringGridHelper.AddRows(ARowCount: Integer);
begin
  Self.RowCount := Self.RowCount + ARowCount;
end;

procedure TStringGridHelper.AddColumns(AColumnCount: Integer;
  ADefaultWidth: Single = 100);
var
  I: Integer;
  Column: TColumn;
begin
  for I := 1 to AColumnCount do
  begin
    Column := TStringColumn.Create(Self);
    Column.Parent := Self;
    Column.Width := ADefaultWidth;
    Column.Header := 'Column ' + IntToStr(Self.ColumnCount);
  end;
end;

procedure TStringGridHelper.SetupGrid(ARowCount, AColumnCount: Integer;
  ADefaultColumnWidth: Single = 100);
var
  I: Integer;
  Column: TColumn;
begin
  // Önce mevcut sütunlarý temizle
  Self.ClearColumns;

  // Yeni sütunlarý ekle
  for I := 0 to AColumnCount - 1 do
  begin
    Column := TStringColumn.Create(Self);
    Column.Parent := Self;
    Column.Width := ADefaultColumnWidth;
    Column.Header := 'Column ' + IntToStr(I + 1);
  end;

  // Satýr sayýsýný ayarla
  Self.RowCount := ARowCount;
end;

procedure TStringGridHelper.SetColumnHeader(AColumnIndex: Integer;
  const AHeader: string);
begin
  if (AColumnIndex >= 0) and (AColumnIndex < Self.ColumnCount) then
    Self.Columns[AColumnIndex].Header := AHeader;
end;

procedure TStringGridHelper.SetColumnHeaders(const AHeaders: array of string);
var
  I: Integer;
begin
  for I := Low(AHeaders) to High(AHeaders) do
  begin
    if I < Self.ColumnCount then
      Self.Columns[I].Header := AHeaders[I];
  end;
end;



end.
