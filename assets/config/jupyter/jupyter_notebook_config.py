# Jupyter Notebook Configuration File

c = get_config()

# Network settings
c.NotebookApp.ip = '127.0.0.1'
c.NotebookApp.open_browser = True
c.NotebookApp.port = 8888

# Security settings
c.NotebookApp.token = ''
c.NotebookApp.password = ''

# Directory settings
c.NotebookApp.notebook_dir = '~/Documents/notebooks'

# Allow root (optional, generally not recommended)
c.NotebookApp.allow_root = False
