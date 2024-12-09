# Grid Trading Bot Setup Scripts

This directory contains modular scripts for setting up different components
of the Grid Trading Bot project.

## Available Scripts

- `setup.sh`: Main setup script that runs everything
- `create_core.sh`: Creates core trading components
- `create_database.sh`: Creates database components
- `create_docs.sh`: Creates documentation
- `create_examples.sh`: Creates example files
- `create_tests.sh`: Creates test files
- `common.sh`: Shared utilities used by other scripts

## Usage

To set up the entire project:
```bash
./setup.sh [project_name]
```

To set up individual components:
```bash
./create_core.sh [project_name]
./create_database.sh [project_name]
./create_docs.sh [project_name]
./create_examples.sh [project_name]
./create_tests.sh [project_name]
```
