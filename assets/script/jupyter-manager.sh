#!/usr/bin/env bash

# Jupyter Manager Script
# Helper script for managing Jupyter notebooks

set -e

NOTEBOOKS_DIR="$HOME/Documents/notebooks"

show_help() {
    echo "Jupyter Manager - Helper script for Jupyter notebooks"
    echo ""
    echo "Usage: jupyter-manager [command]"
    echo ""
    echo "Commands:"
    echo "  start              Start Jupyter Lab"
    echo "  notebook           Start Jupyter Notebook"
    echo "  list-kernels       List installed kernels"
    echo "  install-kernel     Install Python kernel"
    echo "  setup              Setup notebooks directory"
    echo "  help               Show this help message"
}

start_lab() {
    echo "Starting Jupyter Lab..."
    mkdir -p "$NOTEBOOKS_DIR"
    cd "$NOTEBOOKS_DIR"
    jupyter lab
}

start_notebook() {
    echo "Starting Jupyter Notebook..."
    mkdir -p "$NOTEBOOKS_DIR"
    cd "$NOTEBOOKS_DIR"
    jupyter notebook
}

list_kernels() {
    echo "Installed Jupyter kernels:"
    jupyter kernelspec list
}

install_kernel() {
    echo "Installing Python kernel..."
    python -m ipykernel install --user --name python3 --display-name "Python 3.13"
    echo "Kernel installed successfully!"
}

setup_notebooks() {
    echo "Setting up notebooks directory..."
    mkdir -p "$NOTEBOOKS_DIR"
    echo "Notebooks directory created at: $NOTEBOOKS_DIR"
    
    # Create a sample notebook
    if [ ! -f "$NOTEBOOKS_DIR/welcome.ipynb" ]; then
        cat > "$NOTEBOOKS_DIR/welcome.ipynb" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Welcome to Jupyter Notebooks\n",
    "\n",
    "This is a sample notebook to get you started!"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "\n",
    "print(\"All libraries imported successfully!\")\n",
    "print(f\"NumPy version: {np.__version__}\")\n",
    "print(f\"Pandas version: {pd.__version__}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3.13",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.13"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
        echo "Sample notebook created at: $NOTEBOOKS_DIR/welcome.ipynb"
    fi
}

case "${1:-help}" in
    start|lab)
        start_lab
        ;;
    notebook)
        start_notebook
        ;;
    list-kernels|list)
        list_kernels
        ;;
    install-kernel|install)
        install_kernel
        ;;
    setup)
        setup_notebooks
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
