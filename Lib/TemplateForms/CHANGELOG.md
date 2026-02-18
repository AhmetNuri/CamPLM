# Changelog

All notable changes to the FireMonkey Template Forms library will be documented in this file.

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
