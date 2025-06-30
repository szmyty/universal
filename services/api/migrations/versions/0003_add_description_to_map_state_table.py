"""Add description column to map_states table

Revision ID: 0003_add_description_to_map_state_table
Revises: 0002_create_map_state_table
Create Date: 2025-06-23 12:02:00.000000
"""

from alembic import op
import sqlalchemy as sa

# Revision identifiers, used by Alembic.
revision = "0003_add_description_to_map_state_table"
down_revision = "0002_create_map_state_table"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Add description column."""
    op.add_column(
        "map_states",
        sa.Column("description", sa.String(), nullable=False, server_default=""),
    )
    op.alter_column("map_states", "description", server_default=None)


def downgrade() -> None:
    """Remove description column."""
    op.drop_column("map_states", "description")
