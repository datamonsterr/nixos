# Jupyter Notebook Setup Guide

## Overview
Your NixOS system now has a complete Jupyter notebook setup with Python 3.13 and commonly used data science packages.

## What Was Installed

### Python Environment
- **Python 3.13** with the following packages:
  - NumPy
  - OpenCV
  - Pandas
  - Matplotlib
  - JupyterLab
  - Jupyter Notebook
  - IPyKernel
  - IPython
  - UV (Python package manager)

### Jupyter Kernel
- A Python 3.13 kernel has been automatically installed and configured
- Located at: `~/.local/share/jupyter/kernels/python3`

## How to Use

### Quick Start

1. **Start Jupyter Lab** (recommended):
   ```bash
   jlab
   # or
   jupyter lab
   ```

2. **Start Jupyter Notebook** (classic interface):
   ```bash
   jnb
   # or
   jupyter notebook
   ```

### Using the Jupyter Manager Script

After restarting your shell, you'll have access to the `jupyter-manager` command:

```bash
# Show help
jupyter-manager help

# Start Jupyter Lab
jupyter-manager start
# or
jupyter-manager lab

# Start Jupyter Notebook (classic)
jupyter-manager notebook

# List installed kernels
jupyter-manager list-kernels
jupyter-manager list

# Install Python kernel (already done automatically)
jupyter-manager install-kernel

# Setup notebooks directory with sample notebook
jupyter-manager setup
```

### Notebooks Directory

- Default location: `~/Documents/notebooks`
- A sample notebook (`welcome.ipynb`) has been created to help you get started

### Shell Aliases

The following aliases are available (after restarting your shell):

- `jlab` - Launch Jupyter Lab
- `jnb` - Launch Jupyter Notebook
- `jupyter-manager` - Jupyter management script

## Configuration

### Jupyter Configuration File
Located at: `~/.jupyter/jupyter_notebook_config.py`

Default settings:
- Listens on: `127.0.0.1:8888`
- Opens browser automatically
- No token/password (for local use only)
- Default notebook directory: `~/Documents/notebooks`

### Environment Variables
- `JUPYTER_CONFIG_DIR` = `$HOME/.jupyter`
- `JUPYTER_DATA_DIR` = `$HOME/.local/share/jupyter`

## Testing Your Setup

1. Start Jupyter Lab:
   ```bash
   jupyter lab
   ```

2. Create a new notebook or open the sample notebook (`welcome.ipynb`)

3. Test the kernel by running:
   ```python
   import numpy as np
   import pandas as pd
   import matplotlib.pyplot as plt
   
   print("All libraries imported successfully!")
   print(f"NumPy version: {np.__version__}")
   print(f"Pandas version: {pd.__version__}")
   ```

## Verify Installation

Check installed kernels:
```bash
jupyter kernelspec list
```

Expected output:
```
Available kernels:
  python3    /home/dat/.local/share/jupyter/kernels/python3
```

Test Python packages:
```bash
python -c "import numpy, pandas, matplotlib, jupyterlab; print('Success!')"
```

## Additional Packages

To add more Python packages to your Jupyter environment:

1. Edit `/etc/nixos/home/common.nix`
2. Add packages to the `pythonWithPackages` definition:
   ```nix
   pythonWithPackages = pkgs.python313.withPackages (ps: with ps; [
     numpy
     opencv4
     pandas
     matplotlib
     jupyterlab
     ipykernel
     ipython
     jupyter
     notebook
     uv
     # Add your packages here
     # scikit-learn
     # tensorflow
     # etc.
   ]);
   ```
3. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch
   ```

## Troubleshooting

### Kernel not showing up
```bash
jupyter-manager install-kernel
```

### Clear Jupyter cache
```bash
rm -rf ~/.local/share/jupyter/runtime/*
```

### Check Jupyter paths
```bash
jupyter --paths
```

## Next Steps

- Open Jupyter Lab: `jupyter lab`
- Navigate to `~/Documents/notebooks/welcome.ipynb` to see the sample notebook
- Create your own notebooks and start coding!

## Notes

- The Jupyter kernel is automatically set up during system activation
- All configuration is managed through NixOS declarative configuration
- Changes to the Python environment require a system rebuild
