# pgAdmin custom configuration.
# See https://www.pgadmin.org/docs/pgadmin4/latest/config_py.html for more details.
import os

DEFAULT_SERVER_PORT = int(os.getenv("PGADMIN_PORT", 5050))
