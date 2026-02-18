# Changelog

All notable changes to the FireMonkey Template Forms library will be documented in this file.

## [1.1.0] - 2026-02-18

### Added
- **TListBox Class Helper**: JSON import/export support for TListBox
  - `SaveToJSON` method to export all items to JSON array
  - `LoadFromJSON` method to import items from JSON array
  - `ClearItems` method for easy cleanup
  - Preserves item text, data, and selection state
- **TStringGrid Class Helper**: JSON import/export support for TStringGrid
  - `SaveToJSON` method to export grid data (columns and rows) to JSON
  - `LoadFromJSON` method to import grid data from JSON
  - `ClearGrid` method for easy cleanup
  - Preserves column headers, widths, and all cell data
- **Multi-language Support (TLang Component)**:
  - Dynamic language switching at runtime
  - JSON-based translation files
  - Automatic support for TLabel, TButton, TCheckBox, TRadioButton
  - File-based translation management (SaveToFile/LoadFromFile)
  - JSON string-based translation management (SaveToJSON/LoadFromJSON)
  - Integrated into TTemplateForm via `Lang` property
- **Enhanced Example Form** (EnhancedExampleForm.pas):
  - Demonstrates TListBox JSON features
  - Demonstrates TStringGrid JSON features
  - Demonstrates multi-language support with English, Turkish, and German
  - Complete working example with all new features
- **Improved FormController**:
  - Extended to support TListBox and TStringGrid
  - Automatic JSON serialization for complex controls
  - Seamless integration with existing controls

### Changed
- Updated FormController.pas to include TListBox and TStringGrid in data control detection
- Updated FormController.pas GetControlValue to use class helpers
- Updated FormController.pas SetControlValue to use class helpers
- Updated FormController.pas ClearControls to handle TListBox and TStringGrid
- Updated TemplateForm.pas to include TLang component initialization
- Enhanced README.md with comprehensive documentation for new features
- Updated TemplateFormsPkg.dpk to include new units

### Documentation
- Added TListBox usage examples
- Added TStringGrid usage examples
- Added multi-language support usage guide
- Added JSON format examples for TListBox and TStringGrid
- Added translation file format documentation

### New Units
- ListBoxHelper.pas - TListBox class helper for JSON operations
- StringGridHelper.pas - TStringGrid class helper for JSON operations
- LangComponent.pas - TLang component for multi-language support
- EnhancedExampleForm.pas - Enhanced example demonstrating all new features

## [1.0.0] - 2026-02-18

### Added
- Initial release of FireMonkey Template Forms
- Model-View-Controller (MVC) architecture implementation
- Automatic JSON serialization/deserialization for FMX controls
- Support for TEdit, TNumberBox, TMemo, TComboBox, TCheckBox, TRadioButton, TDateEdit, TTimeEdit, TSpinBox
- CRUD operations (Insert, Update, Delete, LoadRecord)
- FireDAC integration for database operations
- Comprehensive error handling with try-except blocks
- Hook methods for customization (BeforeLoadFromJSON, AfterLoadFromJSON, BeforeSaveToJSON, AfterSaveToJSON)
- SOLID principles compliance
- Complete Turkish documentation
- Example customer form implementation
- Database setup SQL scripts for multiple database engines (SQLite, SQL Server, MySQL, PostgreSQL, Oracle)
- Quick reference guide
- Delphi package file (.dpk) for easy integration

### Features
- FormDataModel.pas - Data layer with database operations
- FormController.pas - Controller layer with JSON conversion
- TemplateForm.pas/fmx - Base form with public API
- ExampleCustomerForm.pas/fmx - Complete working example
- Comprehensive README with usage examples
- MIT License

### Documentation
- README.md - Full documentation in Turkish
- QUICKREF.md - Quick reference guide
- DatabaseSetup.sql - Database setup scripts
- ExampleCustomerForm - Working example with all features

### Requirements
- Delphi with FireMonkey (FMX) support
- FireDAC components
- Database with UIJSON field support

### Known Limitations
- Not thread-safe (use from main UI thread only)
- All data entry controls must have unique names
- Requires UIJSON field in database tables
